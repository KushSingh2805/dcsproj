function [symbols, symIdx] = mapBitsToSymbols(bits, constellation, bitsPerAxis)
%MAPBITSTOSYMBOLS Map a bit stream to complex symbols from a constellation.
%   [symbols, symIdx] = mapBitsToSymbols(bits, constellation, bitsPerAxis)
%
% Uses the SAME index convention as buildQAMFromPAM.m: a group of
% 2*bitsPerAxis bits is interpreted as [GrayI bits, GrayQ bits], packed
% into a combined index s = GrayI*2^bitsPerAxis + GrayQ, and
% constellation(s+1) is transmitted. This convention is identical for
% conventional and GS-QAM constellations (only the amplitude values in
% `constellation` differ), which keeps the comparison fair.
%
% Inputs:
%   bits          - column vector of 0/1 bits, length must be a multiple
%                   of bitsPerSymbol = 2*bitsPerAxis
%   constellation - M_QAM x 1 complex constellation vector (indexed
%                   0..M_QAM-1 as produced by buildQAMFromPAM.m)
%   bitsPerAxis   - log2(Mpam)
% Outputs:
%   symbols - Nsym x 1 complex transmitted symbols
%   symIdx  - Nsym x 1 combined symbol index (0..M_QAM-1), useful as the
%             "ground truth" for SER calculation

    bitsPerSymbol = 2*bitsPerAxis;
    bits = bits(:);
    assert(mod(numel(bits), bitsPerSymbol) == 0, ...
        'Bit stream length must be a multiple of %d.', bitsPerSymbol);

    Nsym = numel(bits) / bitsPerSymbol;
    bitMatrix = reshape(bits, bitsPerSymbol, Nsym).';   % Nsym x bitsPerSymbol

    powersOf2 = 2.^(bitsPerSymbol-1:-1:0);
    symIdx = bitMatrix * powersOf2.';                    % Nsym x 1

    symbols = constellation(symIdx + 1);
end
