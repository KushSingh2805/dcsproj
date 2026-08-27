function plotMetricCurves(results, cfg, channelName, metricField, metricLabel, useLogY)
%PLOTMETRICCURVES Shared plotting routine for BER/SER/EVM vs Eb/N0.
%   plotMetricCurves(results, cfg, channelName, metricField, metricLabel, useLogY)
%
% One figure per channel (per Section 14: "prefer separate figures for
% each channel"), with one subplot per modulation order, each subplot
% showing conventional vs GS-QAM as two curves.
%
% Inputs:
%   results     - struct produced by main.m
%   cfg         - config() struct
%   channelName - 'AWGN' | 'Rayleigh' | 'Rician'
%   metricField - 'BER' | 'SER' | 'EVM_percent'
%   metricLabel - y-axis label, e.g. 'BER'
%   useLogY     - true for BER/SER (semilogy), false for EVM

    nM = numel(cfg.M_QAM);
    figure('Name', sprintf('%s vs Eb/N0 - %s', metricLabel, channelName), ...
           'Position', [50 50 1400 450]);

    for i = 1:nM
        M = cfg.M_QAM(i);
        fieldName = sprintf('M%d', M);
        conv = results.(fieldName).(channelName).conventional.(metricField);
        gs = results.(fieldName).(channelName).gsqam.(metricField);

        subplot(1, nM, i);
        if useLogY
            semilogy(cfg.EbN0_dB_range, max(conv, 1e-8), 'b-o', ...
                     cfg.EbN0_dB_range, max(gs, 1e-8), 'r-s');
        else
            plot(cfg.EbN0_dB_range, conv, 'b-o', cfg.EbN0_dB_range, gs, 'r-s');
        end
        grid on;
        xlabel('Eb/N0 (dB)'); ylabel(metricLabel);
        legend('Conventional', 'GS-QAM', 'Location', 'best');
        title(sprintf('%d-QAM', M));
    end

    sgtitle(sprintf('%s vs Eb/N0 - %s channel', metricLabel, channelName));
end
