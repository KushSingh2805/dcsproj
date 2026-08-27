function plotConstellations(results, cfg)
%PLOTCONSTELLATIONS Ideal TX constellations, conventional vs GS-QAM, all M.
%   plotConstellations(results, cfg)
%
% [SPEC Section 13] One figure, 2 x numel(M) grid: top row conventional,
% bottom row GS-QAM, for each modulation order.
%
% Inputs:
%   results - struct produced by main.m (fields M64/M256/M1024, each
%             with .conventional / .gsqam constellation structs)
%   cfg     - config() struct

    figure('Name', 'Ideal TX Constellations', 'Position', [50 50 1400 900]);
    nM = numel(cfg.M_QAM);

    for i = 1:nM
        M = cfg.M_QAM(i);
        fieldName = sprintf('M%d', M);
        convC = results.(fieldName).conventional.constellation;
        gsC = results.(fieldName).gsqam.constellation;
        alpha = results.(fieldName).gsqam.alpha;

        subplot(2, nM, i);
        plot(real(convC), imag(convC), 'b.', 'MarkerSize', 10);
        grid on; axis equal;
        xlabel('I'); ylabel('Q');
        title(sprintf('Conventional %d-QAM', M));

        subplot(2, nM, i+nM);
        plot(real(gsC), imag(gsC), 'r.', 'MarkerSize', 10);
        grid on; axis equal;
        xlabel('I'); ylabel('Q');
        title(sprintf('GS-QAM %d-QAM (\\alpha=%.3f)', M, alpha));
    end
end
