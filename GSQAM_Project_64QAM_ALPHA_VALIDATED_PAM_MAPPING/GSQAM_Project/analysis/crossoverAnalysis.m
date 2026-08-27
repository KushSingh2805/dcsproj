function summary = crossoverAnalysis(results, cfg)
%CROSSOVERANALYSIS Determine, from simulated data only, where/whether
%GS-QAM outperforms conventional QAM.
%   summary = crossoverAnalysis(results, cfg)
%
% [SPEC Section 16] For every M x channel: which scheme has lower BER,
% SER, EVM at each simulated Eb/N0; the lowest Eb/N0 at which GS-QAM
% starts being consistently better (i.e. better at every subsequent
% tested point, not just one noisy sample); and whether the advantage
% (if any) is consistent across the whole swept range. Nothing here is
% assumed -- it is read directly off the simulated BER/SER/EVM arrays.
%
% Inputs:
%   results - struct produced by main.m
%   cfg     - config() struct
% Outputs:
%   summary - struct array, one entry per (M, channel), with fields:
%             M, channel, gsWinsBER (logical vector over EbN0),
%             gsBetterFractionOfRange, crossoverEbN0dB (NaN if GS-QAM
%             never becomes consistently better), consistentAdvantage

    summary = struct([]);
    idxCounter = 0;

    fprintf('\n=== Crossover / Winner Analysis (from simulated data) ===\n');

    for i = 1:numel(cfg.M_QAM)
        M = cfg.M_QAM(i);
        fieldName = sprintf('M%d', M);
        for c = 1:numel(cfg.channels)
            chName = cfg.channels{c};
            conv = results.(fieldName).(chName).conventional;
            gs = results.(fieldName).(chName).gsqam;

            gsWinsBER = gs.BER < conv.BER;
            gsWinsSER = gs.SER < conv.SER;
            gsWinsEVM = gs.EVM_percent < conv.EVM_percent;

            fractionBER = mean(gsWinsBER);

            % Crossover: lowest Eb/N0 index from which GS-QAM wins BER at
            % EVERY subsequent tested point (i.e. a stable win, not a
            % one-off crossing due to Monte Carlo noise).
            crossoverIdx = NaN;
            for k = 1:numel(gsWinsBER)
                if all(gsWinsBER(k:end))
                    crossoverIdx = k;
                    break;
                end
            end
            if isnan(crossoverIdx)
                crossoverEbN0dB = NaN;
            else
                crossoverEbN0dB = cfg.EbN0_dB_range(crossoverIdx);
            end

            consistentAdvantage = all(gsWinsBER) || all(~gsWinsBER);

            idxCounter = idxCounter + 1;
            summary(idxCounter).M = M;
            summary(idxCounter).channel = chName;
            summary(idxCounter).gsWinsBER = gsWinsBER;
            summary(idxCounter).gsWinsSER = gsWinsSER;
            summary(idxCounter).gsWinsEVM = gsWinsEVM;
            summary(idxCounter).gsBetterFractionOfRange = fractionBER;
            summary(idxCounter).crossoverEbN0dB = crossoverEbN0dB;
            summary(idxCounter).consistentAdvantage = consistentAdvantage;

            if isnan(crossoverEbN0dB)
                crossMsg = 'never consistently better across the rest of the sweep';
            else
                crossMsg = sprintf('consistently better from %.1f dB onward', crossoverEbN0dB);
            end
            fprintf('%4d-QAM | %-9s | GS-QAM wins BER at %5.1f%% of tested points | %s\n', ...
                M, chName, 100*fractionBER, crossMsg);
        end
    end

    fprintf('\nNote: "consistently better" requires GS-QAM to win at every\n');
    fprintf('remaining Eb/N0 point, not just a single crossing -- this avoids\n');
    fprintf('reporting a crossover that is really just Monte Carlo noise.\n');
    fprintf('Increase cfg.numSymbols if results look noisy at low-BER points.\n');
end
