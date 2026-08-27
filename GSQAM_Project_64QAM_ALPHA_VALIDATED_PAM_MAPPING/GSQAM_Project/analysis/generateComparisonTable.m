function T = generateComparisonTable(results, cfg, targetEbN0_dB)
%GENERATECOMPARISONTABLE Summary table at one Eb/N0 point for all M/channel.
%   T = generateComparisonTable(results, cfg, targetEbN0_dB)
%
% [SPEC Section 15] Columns: Modulation, Channel, Scheme, BER, SER, EVM,
% plus BER/SER/EVM change relative to conventional, worded as "reduction"
% only when GS-QAM is actually better and "degradation" when it is worse
% -- never mislabeled either way.
%
% Inputs:
%   results       - struct produced by main.m
%   cfg           - config() struct
%   targetEbN0_dB - Eb/N0 (dB) to report at; snapped to the nearest
%                   simulated point in cfg.EbN0_dB_range
% Outputs:
%   T - MATLAB table, also printed to the console and saved to CSV by
%       the caller

    [~, idx] = min(abs(cfg.EbN0_dB_range - targetEbN0_dB));
    actualEbN0 = cfg.EbN0_dB_range(idx);

    rows = {};
    for i = 1:numel(cfg.M_QAM)
        M = cfg.M_QAM(i);
        fieldName = sprintf('M%d', M);
        for c = 1:numel(cfg.channels)
            chName = cfg.channels{c};
            conv = results.(fieldName).(chName).conventional;
            gs = results.(fieldName).(chName).gsqam;

            ber_c = conv.BER(idx); ber_g = gs.BER(idx);
            ser_c = conv.SER(idx); ser_g = gs.SER(idx);
            evm_c = conv.EVM_percent(idx); evm_g = gs.EVM_percent(idx);

            berChangePct = pctChange(ber_c, ber_g);
            serChangePct = pctChange(ser_c, ser_g);
            evmChangePct = pctChange(evm_c, evm_g);

            berWord = describeChange(berChangePct);
            serWord = describeChange(serChangePct);
            evmWord = describeChange(evmChangePct);

            rows(end+1, :) = { M, chName, ber_c, ber_g, berChangePct, berWord, ...
                                ser_c, ser_g, serChangePct, serWord, ...
                                evm_c, evm_g, evmChangePct, evmWord }; %#ok<AGROW>
        end
    end

    T = cell2table(rows, 'VariableNames', ...
        {'M_QAM', 'Channel', 'BER_conventional', 'BER_GSQAM', 'BER_change_pct', 'BER_verdict', ...
         'SER_conventional', 'SER_GSQAM', 'SER_change_pct', 'SER_verdict', ...
         'EVM_pct_conventional', 'EVM_pct_GSQAM', 'EVM_change_pct', 'EVM_verdict'});

    fprintf('\n=== Comparison Table @ Eb/N0 = %.1f dB (nearest simulated point) ===\n', actualEbN0);
    disp(T);
end

function pct = pctChange(baseline, candidate)
% Positive = GS-QAM is better (lower metric value than conventional).
    if baseline == 0
        pct = 0;   % undefined / both effectively zero at this operating point
    else
        pct = 100 * (baseline - candidate) / baseline;
    end
end

function word = describeChange(pctReduction)
% Never call something an "improvement" or "reduction" unless the
% metric actually went down. Ties are reported as "no change".
    if pctReduction > 0.5
        word = sprintf('%.1f%% reduction (GS-QAM better)', pctReduction);
    elseif pctReduction < -0.5
        word = sprintf('%.1f%% degradation (GS-QAM worse)', -pctReduction);
    else
        word = 'no significant change';
    end
end
