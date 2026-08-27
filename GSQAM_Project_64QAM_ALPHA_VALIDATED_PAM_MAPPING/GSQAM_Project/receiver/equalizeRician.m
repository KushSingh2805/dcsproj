function xHat = equalizeRician(rxSymbols, h, minFadingMagnitude)
%EQUALIZERICIAN Zero-forcing equalization under perfect CSI (Rician).
%   xHat = equalizeRician(rxSymbols, h, minFadingMagnitude)
%
% [PAPER: not applicable — Rician fading is not simulated in the paper.]
% Identical zero-forcing procedure to equalizeRayleigh.m; kept as a
% separate file per the requested project architecture (Section 11),
% since the two fading types are conceptually distinct channel models
% even though the equalizer math is the same for both under perfect CSI.
%
% Inputs:
%   rxSymbols          - Nsym x 1 complex received symbols
%   h                  - Nsym x 1 complex fading coefficients (from
%                        ricianChannel.m)
%   minFadingMagnitude - floor applied to |h| before division
% Outputs:
%   xHat - Nsym x 1 equalized complex symbols

    rxSymbols = rxSymbols(:);
    h = h(:);

    hMag = abs(h);
    smallIdx = hMag < minFadingMagnitude;
    if any(smallIdx)
        hSafe = h;
        hSafe(smallIdx) = minFadingMagnitude .* exp(1j*angle(h(smallIdx)));
        h = hSafe;
    end

    xHat = rxSymbols ./ h;
end
