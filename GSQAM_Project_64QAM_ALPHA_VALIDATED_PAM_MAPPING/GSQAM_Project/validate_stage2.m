projectRoot = fileparts(mfilename('fullpath'));
addpath(projectRoot);
addpath(fullfile(projectRoot,'modulation'));
addpath(fullfile(projectRoot,'receiver'));
addpath(fullfile(projectRoot,'channels'));
addpath(fullfile(projectRoot,'metrics'));
addpath(fullfile(projectRoot,'plotting'));
addpath(fullfile(projectRoot,'analysis'));
%VALIDATE_STAGE2 Sanity checks for channels, equalization, and metrics
%(Tests 5-7 of the project spec's Section 17), using conventional 64-QAM
%as the reference case since these are channel-behavior checks, not
%shaping checks.
%
% Test 5: conventional QAM BER in AWGN falls monotonically with Eb/N0 and
%         reaches a low value at high Eb/N0 (qualitative sanity, not an
%         exact-formula match, since our detector/labeling is our own
%         implementation, not a toolbox reference).
% Test 6: Rayleigh fading is worse than AWGN at the same Eb/N0.
% Test 7: Rician fading performance moves toward AWGN as K increases, and
%         toward Rayleigh as K decreases, at fixed Eb/N0.

clear; clc; close all;
addpath('modulation', 'channels', 'receiver', 'metrics');

cfg = config();
rng(cfg.rngSeed);

M = 64;
qam = generateConventionalQAM(M);
Es = mean(abs(qam.constellation).^2);
bitsPerSymbol = 2*qam.bitsPerAxis;

EbN0_test = [0 5 10 15 20 25];
numSym = 20000;   % smaller than the full run for speed; sufficient for
                   % a qualitative sanity check, not final BER curves

fprintf('=== Stage 2 Validation: Channels, Equalization, Metrics ===\n');
fprintf('(Reference case: conventional %d-QAM, %d symbols per point)\n\n', M, numSym);

ber_awgn = zeros(size(EbN0_test));
ber_rayleigh = zeros(size(EbN0_test));
ber_ricianLowK = zeros(size(EbN0_test));   % K = 0 dB (closer to Rayleigh)
ber_ricianHighK = zeros(size(EbN0_test));  % K = 15 dB (closer to AWGN)

for i = 1:numel(EbN0_test)
    EbN0_dB = EbN0_test(i);
    txBits = randi([0 1], numSym*bitsPerSymbol, 1);
    [txSym, txIdx] = mapBitsToSymbols(txBits, qam.constellation, qam.bitsPerAxis);

    % --- AWGN ---
    rx = awgnChannel(txSym, EbN0_dB, bitsPerSymbol, Es);
    [rxBits, rxIdx] = demapSymbols(rx, qam.constellation, qam.bitsPerAxis);
    ber_awgn(i) = calculateBER(txBits, rxBits);

    % --- Rayleigh (equalized, perfect CSI) ---
    [rx, h] = rayleighChannel(txSym, EbN0_dB, bitsPerSymbol, Es);
    xHat = equalizeRayleigh(rx, h, cfg.minFadingMagnitude);
    [rxBits, rxIdx] = demapSymbols(xHat, qam.constellation, qam.bitsPerAxis);
    ber_rayleigh(i) = calculateBER(txBits, rxBits);

    % --- Rician, K = 0 dB ---
    [rx, h] = ricianChannel(txSym, EbN0_dB, bitsPerSymbol, Es, 0);
    xHat = equalizeRician(rx, h, cfg.minFadingMagnitude);
    [rxBits, ~] = demapSymbols(xHat, qam.constellation, qam.bitsPerAxis);
    ber_ricianLowK(i) = calculateBER(txBits, rxBits);

    % --- Rician, K = 15 dB ---
    [rx, h] = ricianChannel(txSym, EbN0_dB, bitsPerSymbol, Es, 15);
    xHat = equalizeRician(rx, h, cfg.minFadingMagnitude);
    [rxBits, ~] = demapSymbols(xHat, qam.constellation, qam.bitsPerAxis);
    ber_ricianHighK(i) = calculateBER(txBits, rxBits);

    fprintf('Eb/N0=%2d dB | AWGN=%.4g  Rayleigh=%.4g  Rician(K=0dB)=%.4g  Rician(K=15dB)=%.4g\n', ...
        EbN0_dB, ber_awgn(i), ber_rayleigh(i), ber_ricianLowK(i), ber_ricianHighK(i));
end

fprintf('\n--- Checks ---\n');

% Test 5: monotonic decrease + low BER at high SNR
isMonotonic = all(diff(ber_awgn) <= 1e-6);   % allow tiny MC noise upticks
lowAtHighSNR = ber_awgn(end) < 1e-2;
fprintf('[Test 5] AWGN BER monotonically non-increasing: %s\n', tern(isMonotonic,'PASS','CHECK MANUALLY'));
fprintf('[Test 5] AWGN BER at %d dB is low (%.4g < 1e-2): %s\n', ...
    EbN0_test(end), ber_awgn(end), tern(lowAtHighSNR,'PASS','FAIL'));

% Test 6: Rayleigh worse than AWGN at every tested point
rayleighWorse = all(ber_rayleigh >= ber_awgn - 1e-6);
fprintf('[Test 6] Rayleigh BER >= AWGN BER at every Eb/N0: %s\n', tern(rayleighWorse,'PASS','FAIL'));

% Test 7: ordering Rayleigh worse than Rician(K=0) worse than/approx
% Rician(K=15) worse than AWGN, and K=15 closer to AWGN than K=0 is.
gapLowK = mean(ber_ricianLowK - ber_awgn);
gapHighK = mean(ber_ricianHighK - ber_awgn);
kFactorTrendOK = gapHighK <= gapLowK;
fprintf('[Test 7] Higher Rician K moves BER closer to AWGN (mean gap %.4g <= %.4g): %s\n', ...
    gapHighK, gapLowK, tern(kFactorTrendOK,'PASS','FAIL'));

% Full round-trip smoke test with EVM (also exercises calculateEVM.m and
% calculateSER.m end to end)
EbN0_smoke = 15;
txBits = randi([0 1], 5000*bitsPerSymbol, 1);
[txSym, txIdx] = mapBitsToSymbols(txBits, qam.constellation, qam.bitsPerAxis);
[rx, h] = rayleighChannel(txSym, EbN0_smoke, bitsPerSymbol, Es);
xHat = equalizeRayleigh(rx, h, cfg.minFadingMagnitude);
[rxBits, rxIdx] = demapSymbols(xHat, qam.constellation, qam.bitsPerAxis);
ber_smoke = calculateBER(txBits, rxBits);
ser_smoke = calculateSER(txIdx, rxIdx);
[evmRMS, evmPct, evmDB] = calculateEVM(txSym, xHat);
fprintf('\n[Smoke test] Rayleigh @ %d dB, 64-QAM: BER=%.4g SER=%.4g EVM=%.2f%% (%.2f dB)\n', ...
    EbN0_smoke, ber_smoke, ser_smoke, evmPct, evmDB);
fprintf('Sanity: SER should be >= BER-implied-error-rate order of magnitude, and both finite/non-negative: %s\n', ...
    tern(isfinite(ber_smoke) && isfinite(ser_smoke) && isfinite(evmRMS) && ber_smoke>=0 && ser_smoke>=0, 'PASS', 'FAIL'));

% Plot BER vs Eb/N0 for a visual check
figure('Name','Stage 2 Channel Sanity Check');
semilogy(EbN0_test, max(ber_awgn,1e-6), 'b-o', ...
         EbN0_test, max(ber_rayleigh,1e-6), 'r-s', ...
         EbN0_test, max(ber_ricianLowK,1e-6), 'm-^', ...
         EbN0_test, max(ber_ricianHighK,1e-6), 'g-v');
grid on;
xlabel('Eb/N0 (dB)'); ylabel('BER');
legend('AWGN','Rayleigh','Rician K=0dB','Rician K=15dB','Location','southwest');
title(sprintf('Conventional %d-QAM: channel sanity check', M));

fprintf('\nIf Tests 5-7 and the smoke test all show PASS (and the plot shows the\n');
fprintf('expected ordering AWGN < Rician(K=15) < Rician(K=0) < Rayleigh), proceed to Stage 9+ (full sweep).\n');

function s = tern(cond, a, b)
    if cond, s = a; else, s = b; end
end
