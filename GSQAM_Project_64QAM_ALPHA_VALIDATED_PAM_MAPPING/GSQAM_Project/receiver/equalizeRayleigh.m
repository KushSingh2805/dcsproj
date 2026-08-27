function xHat = equalizeRayleigh(rxSymbols, h, minFadingMagnitude)
%EQUALIZERAYLEIGH Zero-forcing equalization under perfect CSI (Rayleigh).
%   xHat = equalizeRayleigh(rxSymbols, h, minFadingMagnitude)
%
% [PAPER: not applicable — Rayleigh fading is not simulated in the
% paper.] Implements the spec's Section 6B equalizer:
%   x_hat = y ./ h
% with h magnitude floored at minFadingMagnitude to avoid numerical
% blow-up when a deep fade drives |h| toward zero (Section 18 numerical
% stability requirement). Perfect CSI at the receiver is assumed, as
% stated in the spec.
%
% Inputs:
%   rxSymbols          - Nsym x 1 complex received symbols
%   h                  - Nsym x 1 complex fading coefficients (from
%                        rayleighChannel.m)
%   minFadingMagnitude - floor applied to |h| before division
% Outputs:
%   xHat - Nsym x 1 equalized complex symbols

    rxSymbols = rxSymbols(:);
    h = h(:);

    hMag = abs(h);
    smallIdx = hMag < minFadingMagnitude;
    if any(smallIdx)
        % Preserve phase, floor the magnitude only, so equalization
        % doesn't divide by (near-)zero.
        hSafe = h;
        hSafe(smallIdx) = minFadingMagnitude .* exp(1j*angle(h(smallIdx)));
        h = hSafe;
    end

    xHat = rxSymbols ./ h;
end
