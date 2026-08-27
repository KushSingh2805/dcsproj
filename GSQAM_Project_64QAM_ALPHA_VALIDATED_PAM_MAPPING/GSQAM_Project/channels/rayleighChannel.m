function [rxSymbols, h] = rayleighChannel(txSymbols, EbN0_dB, bitsPerSymbol, Es)
%RAYLEIGHCHANNEL Flat Rayleigh fading channel with AWGN.
%   [rxSymbols, h] = rayleighChannel(txSymbols, EbN0_dB, bitsPerSymbol, Es)
%
% [DEVIATION — not in the paper] Flat-fading Rayleigh channel per Section
% 6B of the spec:
%   y = h*x + n
% where h is a complex Gaussian fading coefficient with E[|h|^2] = 1
% (standard unit-power Rayleigh fading: h = (randn+j*randn)/sqrt(2)), and
% n is the same AWGN model as awgnChannel.m. A new independent h is drawn
% per symbol (flat, fast-fading-per-symbol assumption — see README for
% the "flat vs frequency-selective / block fading" assumption note).
%
% Inputs:
%   txSymbols     - Nsym x 1 complex transmitted symbols
%   EbN0_dB       - scalar, Eb/N0 in dB
%   bitsPerSymbol - bits per complex symbol
%   Es            - average transmitted symbol energy (~1)
% Outputs:
%   rxSymbols - Nsym x 1 complex received symbols
%   h         - Nsym x 1 complex fading coefficients (returned so the
%               receiver can equalize under the "perfect CSI" assumption
%               stated in the spec, Section 6B)

    txSymbols = txSymbols(:);
    Nsym = numel(txSymbols);

    h = (randn(Nsym,1) + 1j*randn(Nsym,1)) / sqrt(2);   % E[|h|^2] = 1

    EbN0_lin = 10^(EbN0_dB/10);
    N0 = Es / (EbN0_lin * bitsPerSymbol);
    n = sqrt(N0/2) * (randn(Nsym,1) + 1j*randn(Nsym,1));

    rxSymbols = h .* txSymbols + n;
end
