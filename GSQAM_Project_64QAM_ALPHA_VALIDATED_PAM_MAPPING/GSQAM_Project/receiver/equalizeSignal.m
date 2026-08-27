function xHat = equalizeSignal(rxSymbols, h, channelName, minFadingMagnitude)
%EQUALIZESIGNAL Dispatch to the appropriate equalizer (or pass through).
%   xHat = equalizeSignal(rxSymbols, h, channelName, minFadingMagnitude)
%
% Inputs:
%   rxSymbols           - Nsym x 1 complex received symbols
%   h                    - Nsym x 1 fading coefficients, or [] for AWGN
%   channelName          - 'AWGN' | 'Rayleigh' | 'Rician'
%   minFadingMagnitude   - floor for |h| passed to the fading equalizers
% Outputs:
%   xHat - Nsym x 1 equalized (or, for AWGN, unmodified) symbols

    switch channelName
        case 'AWGN'
            xHat = rxSymbols;   % no fading to equalize
        case 'Rayleigh'
            xHat = equalizeRayleigh(rxSymbols, h, minFadingMagnitude);
        case 'Rician'
            xHat = equalizeRician(rxSymbols, h, minFadingMagnitude);
        otherwise
            error('Unknown channel: %s', channelName);
    end
end
