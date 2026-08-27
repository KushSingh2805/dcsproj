function plotEVM(results, cfg, channelName)
%PLOTEVM EVM(%) vs Eb/N0, conventional vs GS-QAM, one figure per channel.
%   plotEVM(results, cfg, channelName)
    plotMetricCurves(results, cfg, channelName, 'EVM_percent', 'EVM (%)', false);
end
