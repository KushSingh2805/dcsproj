%VALIDATE_STAGE1 Sanity checks + constellation plots for Stages 2-4.
%   Run this BEFORE moving on to channels/metrics (Section 17 and
%   Section 24 of the project spec: validate at every stage before
%   proceeding). This script covers Tests 1-4 of Section 17 for the
%   noiseless / structural checks (Tests 5-7, which need a channel, will
%   be added in the next stage's validation script).

clear; clc; close all;
projectRoot = fileparts(mfilename('fullpath'));
addpath(projectRoot);
addpath(fullfile(projectRoot,'modulation'));
addpath(fullfile(projectRoot,'receiver'));
addpath(fullfile(projectRoot,'channels'));
addpath(fullfile(projectRoot,'metrics'));
addpath(fullfile(projectRoot,'plotting'));
addpath(fullfile(projectRoot,'analysis'));

cfg = config();

fprintf('=== Stage 1-4 Validation: Conventional QAM vs GS-QAM ===\n\n');

figure('Name','Constellations','Position',[50 50 1400 900]);
tileIdx = 1;

for i = 1:numel(cfg.M_QAM)
    M = cfg.M_QAM(i);
    designEbN0 = cfg.designEbN0_dB;

    fprintf('--- M = %d-QAM (Mpam = %d) ---\n', M, sqrt(M));

    % ---- Conventional QAM ----
    convQ = generateConventionalQAM(M);

    % Test 1: correct number of points
    assert(numel(convQ.constellation) == M, 'Conventional: wrong point count');
    assert(numel(unique(convQ.constellation)) == M, 'Conventional: duplicate points');
    fprintf('  [Test 1] Conventional QAM has %d unique points: PASS\n', M);

    % Test 3: energy normalization
    Es_conv = mean(abs(convQ.constellation).^2);
    fprintf('  [Test 3] Conventional mean(|s|^2) = %.6f (target 1.0): %s\n', ...
        Es_conv, tern(abs(Es_conv-1)<cfg.energyTolerance,'PASS','FAIL'));

    % ---- GS-QAM ----
    tic;
    gsQ = generateGSQAM(M, designEbN0);
    tElapsed = toc;

    % Test 2: correct number of unique points
    assert(numel(gsQ.constellation) == M, 'GS-QAM: wrong point count');
    assert(numel(unique(gsQ.constellation)) == M, 'GS-QAM: duplicate points');
    fprintf('  [Test 2] GS-QAM has %d unique points: PASS\n', M);

    % Test 3: energy normalization
    Es_gs = mean(abs(gsQ.constellation).^2);
    fprintf('  [Test 3] GS-QAM mean(|s|^2) = %.6f (target 1.0): %s\n', ...
        Es_gs, tern(abs(Es_gs-1)<cfg.energyTolerance,'PASS','FAIL'));

    fprintf('  Optimized alpha* = %.4f (design Eb/N0 = %.1f dB), CM capacity = %.4f bits/dim [%.1fs]\n', ...
        gsQ.alpha, designEbN0, gsQ.capacityAtAlpha, tElapsed);

    % Test 4: noiseless round-trip (bits in == bits out)
    rng(cfg.rngSeed);
    bitsPerSymbol = 2*convQ.bitsPerAxis;
    nTestSym = 2000;
    txBits = randi([0 1], nTestSym*bitsPerSymbol, 1);

    [txSym_c, idx_c] = mapBitsToSymbols(txBits, convQ.constellation, convQ.bitsPerAxis);
    [rxBits_c, idx_c_hat] = demapSymbols(txSym_c, convQ.constellation, convQ.bitsPerAxis);
    ber_c = mean(rxBits_c ~= txBits);
    ser_c = mean(idx_c_hat ~= idx_c);

    [txSym_g, idx_g] = mapBitsToSymbols(txBits, gsQ.constellation, gsQ.bitsPerAxis);
    [rxBits_g, idx_g_hat] = demapSymbols(txSym_g, gsQ.constellation, gsQ.bitsPerAxis);
    ber_g = mean(rxBits_g ~= txBits);
    ser_g = mean(idx_g_hat ~= idx_g);

    fprintf('  [Test 4] Noiseless round-trip: Conventional BER=%.g SER=%.g | GS-QAM BER=%.g SER=%.g : %s\n', ...
        ber_c, ser_c, ber_g, ser_g, tern(ber_c==0 && ser_c==0 && ber_g==0 && ser_g==0,'PASS','FAIL'));

    % ---- Plot ----
    subplot(2,3,tileIdx);
    plot(real(convQ.constellation), imag(convQ.constellation), 'b.', 'MarkerSize', 10);
    grid on; axis equal;
    xlabel('I'); ylabel('Q');
    title(sprintf('Conventional %d-QAM', M));

    subplot(2,3,tileIdx+3);
    plot(real(gsQ.constellation), imag(gsQ.constellation), 'r.', 'MarkerSize', 10);
    grid on; axis equal;
    xlabel('I'); ylabel('Q');
    title(sprintf('GS-QAM %d (\\alpha=%.3f)', M, gsQ.alpha));

    tileIdx = tileIdx + 1;

    % save for next stage
    results.(sprintf('M%d', M)).conventional = convQ;
    results.(sprintf('M%d', M)).gsqam = gsQ;

    fprintf('\n');
end

if ~exist('results', 'dir'), mkdir('results'); end
save('results/stage1_constellations.mat', 'results', 'cfg');
fprintf('Saved results/stage1_constellations.mat\n');
fprintf('If all tests above show PASS, proceed to Stage 5 (channels).\n');

function s = tern(cond, a, b)
    if cond, s = a; else, s = b; end
end
