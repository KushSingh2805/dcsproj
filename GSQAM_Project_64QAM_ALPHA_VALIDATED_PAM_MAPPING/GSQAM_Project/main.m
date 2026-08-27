projectRoot = fileparts(mfilename('fullpath'));
addpath(projectRoot);
addpath(fullfile(projectRoot,'modulation'));
addpath(fullfile(projectRoot,'receiver'));
addpath(fullfile(projectRoot,'channels'));
addpath(fullfile(projectRoot,'metrics'));
addpath(fullfile(projectRoot,'plotting'));
addpath(fullfile(projectRoot,'analysis'));
%MAIN Full Monte Carlo sweep: 64-QAM only x {AWGN,Rayleigh,Rician}
%x {conventional, GS-QAM}, producing paired BER/SER/EVM curves, constellation
%plots, comparison tables, and a crossover/winner analysis.
%
% Run validate_stage1.m and validate_stage2.m first and confirm all
% checks pass before running this (Section 24 of the project spec).
%
% Runtime note: with the default cfg.numSymbols = 1e5 and the paired
% early-stop in runPairedSimulationPoint.m (min 100 bit errors for BOTH
% schemes, cap maxSymbolsPerPoint), the full sweep is
%   3 modulation orders x 3 channels x 2 schemes x numel(EbN0_dB_range)
% Monte Carlo points. This can take a while, especially at high Eb/N0 for
% 1024-QAM where many symbols may be needed to accumulate enough errors.
% Reduce cfg.EbN0_dB_range or cfg.numSymbols in config.m for a faster
% first pass; increase for smoother final curves.

clear; clc; close all;
addpath('modulation', 'channels', 'receiver', 'metrics', 'plotting', 'analysis');

cfg = config();
rng(cfg.rngSeed);

fprintf('=== 64-QAM Simulation Sweep ===\n');
fprintf('M_QAM = %s | channels = %s | Eb/N0 = %d:%d:%d dB | numSymbols(base) = %g\n\n', ...
    mat2str(cfg.M_QAM), strjoin(cfg.channels, ', '), ...
    cfg.EbN0_dB_range(1), cfg.EbN0_dB_range(2)-cfg.EbN0_dB_range(1), cfg.EbN0_dB_range(end), ...
    cfg.numSymbols);

results = struct();

for i = 1:numel(cfg.M_QAM)
    M = cfg.M_QAM(i);
    fieldName = sprintf('M%d', M);
    designEbN0 = cfg.designEbN0_dB;

    fprintf('--- %d-QAM (design Eb/N0 for alpha = %.1f dB) ---\n', M, designEbN0);

    convQ = generateConventionalQAM(M);
    gsQ = generateGSQAM(M, designEbN0);
    fprintf('  alpha* = %.4f, CM capacity at design point = %.4f bits/dim\n', ...
        gsQ.alpha, gsQ.capacityAtAlpha);

    results.(fieldName).conventional = convQ;
    results.(fieldName).gsqam = gsQ;

    for c = 1:numel(cfg.channels)
        chName = cfg.channels{c};
        nPts = numel(cfg.EbN0_dB_range);

        BER_c = zeros(1,nPts); SER_c = zeros(1,nPts); EVM_c = zeros(1,nPts); EVMdB_c = zeros(1,nPts);
        BER_g = zeros(1,nPts); SER_g = zeros(1,nPts); EVM_g = zeros(1,nPts); EVMdB_g = zeros(1,nPts);
        nSyms = zeros(1,nPts);

        fprintf('  [%s] ', chName);
        for e = 1:nPts
            EbN0_dB = cfg.EbN0_dB_range(e);

            % IMPORTANT: paired simulation uses identical bits, fading and
            % noise for conventional and GS-QAM. This isolates the effect
            % of the constellation geometry from Monte-Carlo randomness.
            rp = runPairedSimulationPoint(convQ.constellation, gsQ.constellation, ...
                convQ.bitsPerAxis, chName, EbN0_dB, cfg);

            rc = rp.conventional;
            rg = rp.gsqam;

            BER_c(e) = rc.BER; SER_c(e) = rc.SER; EVM_c(e) = rc.EVM_percent; EVMdB_c(e) = rc.EVM_dB;
            BER_g(e) = rg.BER; SER_g(e) = rg.SER; EVM_g(e) = rg.EVM_percent; EVMdB_g(e) = rg.EVM_dB;
            nSyms(e) = rp.sharedN0Trials;

            fprintf('.');
        end
        fprintf(' done\n');

        results.(fieldName).(chName).conventional.BER = BER_c;
        results.(fieldName).(chName).conventional.SER = SER_c;
        results.(fieldName).(chName).conventional.EVM_percent = EVM_c;
        results.(fieldName).(chName).conventional.EVM_dB = EVMdB_c;
        results.(fieldName).(chName).conventional.nSymbolsUsed = nSyms;

        results.(fieldName).(chName).gsqam.BER = BER_g;
        results.(fieldName).(chName).gsqam.SER = SER_g;
        results.(fieldName).(chName).gsqam.EVM_percent = EVM_g;
        results.(fieldName).(chName).gsqam.EVM_dB = EVMdB_g;
        results.(fieldName).(chName).gsqam.nSymbolsUsed = nSyms;
    end
    fprintf('\n');
end

%% Save results ---------------------------------------------------------
if ~exist('results', 'dir'), mkdir('results'); end
save('results/full_simulation_results.mat', 'results', 'cfg');
fprintf('Saved results/full_simulation_results.mat\n\n');

%% Constellation plots (Stage 13) ---------------------------------------
plotConstellations(results, cfg);

% PAM mapping plots: raw and normalized conventional/GS PAM
plotPAMMappings(results, cfg);

repEbN0 = cfg.EbN0_dB_range(round(numel(cfg.EbN0_dB_range)/2));   % mid-range SNR
plotReceivedConstellations(results, cfg, repEbN0);

%% Performance plots (Stage 14) ------------------------------------------
for c = 1:numel(cfg.channels)
    chName = cfg.channels{c};
    plotBER(results, cfg, chName);
    plotSER(results, cfg, chName);
    plotEVM(results, cfg, chName);
end

%% Comparison table (Stage 15) -------------------------------------------
targetEbN0 = cfg.EbN0_dB_range(round(numel(cfg.EbN0_dB_range)*0.7));  % a representative, reasonably high SNR point
T = generateComparisonTable(results, cfg, targetEbN0);
writetable(T, 'results/comparison_table.csv');
fprintf('Saved results/comparison_table.csv\n');

%% Crossover / winner analysis (Stage 16) ---------------------------------
summary = crossoverAnalysis(results, cfg);
save('results/crossover_summary.mat', 'summary');
fprintf('Saved results/crossover_summary.mat\n');

fprintf('\n=== Done. See the figures, results/comparison_table.csv, and the\n');
fprintf('console output above for the crossover analysis. ===\n');
