function plotBER(results, cfg, channelName)
%PLOTBER BER vs Eb/N0, conventional vs GS-QAM, one figure per channel.
%   plotBER(results, cfg, channelName)
    plotMetricCurves(results, cfg, channelName, 'BER', 'BER', true);
end
