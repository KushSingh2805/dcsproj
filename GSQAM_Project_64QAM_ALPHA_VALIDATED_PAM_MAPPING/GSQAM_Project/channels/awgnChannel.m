function rxSymbols = awgnChannel(txSymbols, EbN0_dB, bitsPerSymbol, Es)
%AWGNCHANNEL Additive white Gaussian noise channel.
%   rxSymbols = awgnChannel(txSymbols, EbN0_dB, bitsPerSymbol, Es)
%
% Model: y = x + n   [DEVIATION: this exact model is your spec's Section
% 6A, not something the paper simulates in an uncoded form — the paper's
% own channel model, Eq. (1), is the same AWGN model but used only to
% derive capacity/BER for CODED systems.]
%
% Noise variance is derived from Eb/N0 (dB) and the average symbol
% energy Es (should be 1 for both schemes here, since both are
% normalized to mean(|s|^2)=1 — this is what makes the comparison fair):
%   EbN0_lin = 10^(EbN0_dB/10)
%   N0 = Es / (EbN0_lin * bitsPerSymbol)
%   noise ~ CN(0, N0), i.e. independent real/imag parts each N(0, N0/2)
%
% Inputs:
%   txSymbols     - Nsym x 1 complex transmitted symbols
%   EbN0_dB       - scalar, bit-energy-to-noise-density ratio in dB
%   bitsPerSymbol - bits carried per complex symbol (log2(M_QAM))
%   Es            - average transmitted symbol energy (pass
%                   mean(abs(constellation).^2), should be ~1)
% Outputs:
%   rxSymbols - Nsym x 1 complex received symbols

    EbN0_lin = 10^(EbN0_dB/10);
    N0 = Es / (EbN0_lin * bitsPerSymbol);

    txSymbols = txSymbols(:);
    n = sqrt(N0/2) * (randn(size(txSymbols)) + 1j*randn(size(txSymbols)));

    rxSymbols = txSymbols + n;
end
