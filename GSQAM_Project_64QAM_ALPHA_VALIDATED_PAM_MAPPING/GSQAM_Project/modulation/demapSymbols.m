function [bitsHat, symIdxHat] = demapSymbols(rxSymbols, constellation, bitsPerAxis)
%DEMAPSYMBOLS Detect symbols (via receiver/minimumDistanceDetector.m) and
%recover bits.
%   [bitsHat, symIdxHat] = demapSymbols(rxSymbols, constellation, bitsPerAxis)
%
% Thin wrapper: detection itself lives in
% receiver/minimumDistanceDetector.m (kept separate per the project's
% modular architecture); this function just adds the bit-recovery step
% using the exact inverse of the packing done in mapBitsToSymbols.m.
%
% Inputs:
%   rxSymbols     - Nsym x 1 received/equalized complex symbols
%   constellation - M_QAM x 1 complex constellation (0-indexed
%                   convention as in buildQAMFromPAM.m)
%   bitsPerAxis   - log2(Mpam)
% Outputs:
%   bitsHat    - (Nsym*bitsPerSymbol) x 1 recovered bit stream
%   symIdxHat  - Nsym x 1 detected combined symbol index (0..M_QAM-1)

    bitsPerSymbol = 2*bitsPerAxis;
    M_QAM = numel(constellation);

    symIdxHat = minimumDistanceDetector(rxSymbols, constellation);

    Nsym = numel(symIdxHat);
    bitMatrix = zeros(Nsym, bitsPerSymbol);
    remaining = symIdxHat;
    for b = bitsPerSymbol:-1:1
        bitMatrix(:, b) = mod(remaining, 2);
        remaining = floor(remaining / 2);
    end
    bitsHat = reshape(bitMatrix.', [], 1);

    assert(all(symIdxHat >= 0 & symIdxHat < M_QAM), ...
        'Detected symbol index out of range.');
end
