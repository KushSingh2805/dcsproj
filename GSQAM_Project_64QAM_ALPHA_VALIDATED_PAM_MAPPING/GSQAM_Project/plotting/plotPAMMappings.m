function plotPAMMappings(results, cfg)
%PLOTPAMMAPPINGS Plot raw and normalized PAM mappings.
%
% For each modulation order, this shows:
%   1) raw conventional PAM
%   2) raw GS-PAM
%   3) normalized conventional PAM
%   4) normalized GS-PAM
%
% The raw plots show the actual mapping produced before energy scaling.
% The normalized plots show the levels used by the QAM simulation.

    figure('Name', 'PAM Mapping: Raw vs Normalized', ...
           'Position', [80 50 1500 1000]);

    nM = numel(cfg.M_QAM);

    for i = 1:nM
        M = cfg.M_QAM(i);
        fieldName = sprintf('M%d', M);

        convQ = results.(fieldName).conventional;
        gsQ   = results.(fieldName).gsqam;

        k = 0:(convQ.Mpam-1);

        % ---- Raw conventional PAM ----
        subplot(4, nM, i);
        stem(k, convQ.pamLevelsRaw, 'filled');
        grid on;
        xlabel('PAM index k');
        ylabel('Amplitude');
        title(sprintf('Raw Conventional %d-PAM', convQ.Mpam));

        % ---- Raw GS PAM ----
        subplot(4, nM, i+nM);
        stem(k, gsQ.pamLevelsRaw, 'filled');
        grid on;
        xlabel('PAM index k');
        ylabel('Amplitude');
        title(sprintf('Raw GS %d-PAM (\\alpha=%.4f)', gsQ.Mpam, gsQ.alpha));

        % ---- Normalized conventional PAM ----
        subplot(4, nM, i+2*nM);
        stem(k, convQ.pamLevels, 'filled');
        grid on;
        xlabel('PAM index k');
        ylabel('Amplitude');
        title(sprintf('Normalized Conventional %d-PAM', convQ.Mpam));

        % ---- Normalized GS PAM ----
        subplot(4, nM, i+3*nM);
        stem(k, gsQ.pamLevels, 'filled');
        grid on;
        xlabel('PAM index k');
        ylabel('Amplitude');
        title(sprintf('Normalized GS %d-PAM (\\alpha=%.4f)', gsQ.Mpam, gsQ.alpha));
    end

    sgtitle('PAM Mapping: Before and After Energy Normalization');
end
