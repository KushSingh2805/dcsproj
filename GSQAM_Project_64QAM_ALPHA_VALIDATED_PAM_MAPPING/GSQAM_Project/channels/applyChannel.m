function [rxSymbols, h] = applyChannel(txSymbols, channelName, EbN0_dB, bitsPerSymbol, Es, ricianK_dB)
%APPLYCHANNEL Dispatch to the requested channel model.
%   [rxSymbols, h] = applyChannel(txSymbols, channelName, EbN0_dB, ...
%                                  bitsPerSymbol, Es, ricianK_dB)
%
% Thin dispatcher over awgnChannel.m / rayleighChannel.m / ricianChannel.m
% so main.m's sweep loop doesn't repeat the same if/else in multiple
% places. h is empty for AWGN (no fading to equalize).
%
% Inputs:
%   txSymbols      - Nsym x 1 complex transmitted symbols
%   channelName    - 'AWGN' | 'Rayleigh' | 'Rician'
%   EbN0_dB        - scalar, Eb/N0 in dB
%   bitsPerSymbol  - bits per complex symbol
%   Es             - average transmitted symbol energy
%   ricianK_dB     - Rician K-factor in dB (used only if channelName is 'Rician')
% Outputs:
%   rxSymbols - Nsym x 1 complex received symbols
%   h         - Nsym x 1 complex fading coefficients, or [] for AWGN

    switch channelName
        case 'AWGN'
            rxSymbols = awgnChannel(txSymbols, EbN0_dB, bitsPerSymbol, Es);
            h = [];
        case 'Rayleigh'
            [rxSymbols, h] = rayleighChannel(txSymbols, EbN0_dB, bitsPerSymbol, Es);
        case 'Rician'
            [rxSymbols, h] = ricianChannel(txSymbols, EbN0_dB, bitsPerSymbol, Es, ricianK_dB);
        otherwise
            error('Unknown channel: %s', channelName);
    end
end
