function validate_paper_alpha()
%VALIDATE_PAPER_ALPHA Validate the GS shaping optimizer against the paper.
%
% Reference case from the uploaded paper:
%   M = 32-PAM
%   QAM Es/N0 = 26.50 dB
%   CM-capacity optimum alpha ~= 0.882
%   CCM ~= 4.262 bits/dimension
%
% Important: the paper's 26.50 dB is Es/N0 with Es defined for the
% corresponding QAM symbol. Therefore this validation passes 26.50 dB
% directly to computeCMCapacity, whose noise variance uses Es_QAM = 1.

root = fileparts(mfilename('fullpath'));
addpath(root);
addpath(fullfile(root,'modulation'));

fprintf('\n=== Paper Reference Alpha Validation ===\n');
M = 32;
paperEsN0_dB = 26.50;
expectedAlpha = 0.882;
expectedCCM = 4.262;

[alphaStar, ccm] = optimizeAlpha(M, paperEsN0_dB, [0,1]);

fprintf('  32-PAM, QAM Es/N0 = %.2f dB\n', paperEsN0_dB);
fprintf('  Optimized alpha* = %.4f (paper ~= %.3f)\n', alphaStar, expectedAlpha);
fprintf('  CM capacity      = %.4f bits/dim (paper ~= %.3f)\n', ccm, expectedCCM);

assert(abs(alphaStar - expectedAlpha) < 0.02, ...
    'Alpha validation failed: optimizer does not reproduce the paper reference.');
assert(abs(ccm - expectedCCM) < 0.02, ...
    'Capacity validation failed: optimizer does not reproduce the paper reference.');

fprintf('  [PASS] Paper alpha reference reproduced within tolerance.\n');
fprintf('  [PASS] Capacity reference reproduced within tolerance.\n');

% Show the actual 32-PAM shaped points for visual inspection.
k = (0:M-1)';
aHat = erfinv(alphaStar * ((2*k+1)/M - 1));
a = normalizeShapedPAM(aHat, M);

fprintf('  Normalized 32-PAM axis energy = %.6f (target 0.5)\n', mean(a.^2));

figure('Name','Paper Reference: 32-PAM GS');
plot(a, zeros(size(a)), 'o', 'MarkerSize', 6);
grid on;
xlabel('Amplitude');
yticks([]);
title(sprintf('Paper Reference 32-PAM GS, \\alpha = %.3f', alphaStar));
end
