function plotSER(results, cfg, channelName)
%PLOTSER SER vs Eb/N0, conventional vs GS-QAM, one figure per channel.
%   plotSER(results, cfg, channelName)
    plotMetricCurves(results, cfg, channelName, 'SER', 'SER', true);
end
