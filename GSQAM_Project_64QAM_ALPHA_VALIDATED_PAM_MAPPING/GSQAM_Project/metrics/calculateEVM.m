function [evmRMS, evmPercent, evmDB] = calculateEVM(idealSymbols, receivedSymbols)
%CALCULATEEVM RMS Error Vector Magnitude between ideal and received symbols.
%   [evmRMS, evmPercent, evmDB] = calculateEVM(idealSymbols, receivedSymbols)
%
% [NOT IN PAPER — user-specified metric, Section 9] Formula:
%   evmRMS = sqrt( sum(|r - s|^2) / sum(|s|^2) )
%   evmPercent = 100 * evmRMS
%   evmDB = 20*log10(evmRMS)
%
% [ASSUMPTION, stated once and applied consistently] `receivedSymbols`
% must be the EQUALIZED symbols (post zero-forcing equalization for
% Rayleigh/Rician, or the raw AWGN-channel output for AWGN, since no
% equalization is needed there). This is the standard EVM convention:
% EVM measures the residual distortion (mainly noise) after the channel
% response has been compensated, not the raw fading distortion itself.
% The same convention is used for both conventional and GS-QAM so the
% comparison is fair.
%
% Inputs:
%   idealSymbols    - N x 1 ideal transmitted constellation points
%   receivedSymbols - N x 1 received (and, for fading channels,
%                     equalized) symbols, same length as idealSymbols
% Outputs:
%   evmRMS     - scalar, RMS EVM (unitless ratio)
%   evmPercent - scalar, RMS EVM in percent
%   evmDB      - scalar, RMS EVM in dB

    idealSymbols = idealSymbols(:);
    receivedSymbols = receivedSymbols(:);
    assert(numel(idealSymbols) == numel(receivedSymbols), ...
        'idealSymbols and receivedSymbols must have the same length.');

    evmRMS = sqrt( sum(abs(receivedSymbols - idealSymbols).^2) / ...
                   sum(abs(idealSymbols).^2) );
    evmPercent = 100 * evmRMS;
    evmDB = 20*log10(evmRMS);
end
