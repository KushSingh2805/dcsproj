function [alphaStar, capacityAtAlphaStar] = optimizeAlpha(Mpam, designEsN0_dB, alphaRange)
%OPTIMIZEALPHA Find the shaping parameter alpha maximizing CM capacity.
%   [alphaStar, capAtStar] = optimizeAlpha(Mpam, designEsN0_dB, alphaRange)
%
% Based on the paper's stated procedure (Section III-C1): "we numerically
% evaluate the ... constellations ... where the parameter is optimized
% based on the resulting mutual information", e.g. "the maximum value of
% nearly 4.262 is reached at alpha = 0.882" for 32-PAM at Es/N0=26.5 dB.
%
% [ASSUMPTION] The paper performs this search once per (M, design SNR)
% pair via direct numerical evaluation over a grid of alpha (Fig. 5). We
% reproduce that with a bounded scalar optimizer (fminbnd) over the
% closed-form-quadrature capacity from computeCMCapacity.m, which is
% mathematically the same objective, just optimized rather than
% grid-swept, for speed and precision.
%
% Inputs:
%   Mpam          - PAM constellation size (e.g. 8, 16, 32)
%   designEsN0_dB - design-point per-PAM-symbol SNR in dB at which alpha
%                   is optimized (see config.m for how this maps from
%                   the requested design Eb/N0)
%   alphaRange    - [lo hi], defaults to [0,1] per Eq. (30)
% Outputs:
%   alphaStar           - optimal shaping parameter in [0,1]
%   capacityAtAlphaStar - CM capacity (bits/PAM-dim) achieved at alphaStar

    if nargin < 3 || isempty(alphaRange)
        alphaRange = [0, 1];
    end

    k = (0:Mpam-1)';

    objective = @(alpha) -capacityForAlpha(alpha, Mpam, k, designEsN0_dB);

    % fminbnd avoids alpha = 0 exactly (erfinv(0)=0 for all k -> singular
    % degenerate case handled fine, but keep a tiny margin from alpha=0
    % for numerical robustness of erfinv near its domain edges).
    lo = max(alphaRange(1), 1e-4);
    hi = min(alphaRange(2), 1 - 1e-9);

    opts = optimset('TolX', 1e-4, 'Display', 'off');
    [alphaStar, negCap] = fminbnd(objective, lo, hi, opts);
    capacityAtAlphaStar = -negCap;
end

function CCM = capacityForAlpha(alpha, Mpam, k, designEsN0_dB)
    aHat = erfinv( alpha * ((2*k + 1)/Mpam - 1) );   % Eq. (29)
    a = normalizeShapedPAM(aHat, Mpam);              % Eq. (23) constraint
    CCM = computeCMCapacity(a, designEsN0_dB);
end
