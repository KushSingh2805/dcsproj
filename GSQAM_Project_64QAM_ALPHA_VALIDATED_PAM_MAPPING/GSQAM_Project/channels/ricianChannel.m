function [rxSymbols, h] = ricianChannel(txSymbols, EbN0_dB, bitsPerSymbol, Es, K_dB)
%RICIANCHANNEL Flat Rician fading channel with AWGN.
%   [rxSymbols, h] = ricianChannel(txSymbols, EbN0_dB, bitsPerSymbol, Es, K_dB)
%
% [DEVIATION — not in the paper] Flat Rician fading per Section 6C of the
% spec:
%   y = h*x + n
% h = LOS component + scattered component, normalized to E[|h|^2] = 1:
%   K_lin  = 10^(K_dB/10)
%   sLOS   = sqrt(K_lin/(K_lin+1))                (deterministic, real)
%   sigma  = sqrt(1/(2*(K_lin+1)))                (per real/imag dim)
%   h = sLOS + sigma*(randn + j*randn)
% As K_dB -> -Inf this reduces to Rayleigh (sLOS->0); as K_dB -> +Inf,
% h -> 1 (pure LOS, approaches the AWGN-only case). K_dB is a
% configurable parameter (config.m), default 5 dB per the spec.
%
% Inputs:
%   txSymbols     - Nsym x 1 complex transmitted symbols
%   EbN0_dB       - scalar, Eb/N0 in dB
%   bitsPerSymbol - bits per complex symbol
%   Es            - average transmitted symbol energy (~1)
%   K_dB          - Rician K-factor in dB
% Outputs:
%   rxSymbols - Nsym x 1 complex received symbols
%   h         - Nsym x 1 complex fading coefficients (perfect CSI assumed
%               at the receiver, as stated in the spec, Section 6C)

    txSymbols = txSymbols(:);
    Nsym = numel(txSymbols);

    K_lin = 10^(K_dB/10);
    sLOS = sqrt(K_lin/(K_lin+1));
    sigma = sqrt(1/(2*(K_lin+1)));

    h = sLOS + sigma*(randn(Nsym,1) + 1j*randn(Nsym,1));

    EbN0_lin = 10^(EbN0_dB/10);
    N0 = Es / (EbN0_lin * bitsPerSymbol);
    n = sqrt(N0/2) * (randn(Nsym,1) + 1j*randn(Nsym,1));

    rxSymbols = h .* txSymbols + n;
end
