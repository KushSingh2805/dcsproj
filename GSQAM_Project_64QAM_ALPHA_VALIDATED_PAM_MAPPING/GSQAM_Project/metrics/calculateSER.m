function ser = calculateSER(txSymIdx, rxSymIdx)
%CALCULATESER Symbol error rate from transmitted vs detected symbol indices.
%   ser = calculateSER(txSymIdx, rxSymIdx)
%
% [SPEC Section 8] Compares transmitted symbol indices with detected
% symbol indices (from minimumDistanceDetector.m against the actual
% constellation in use — standard or shaped).
%
% Inputs:
%   txSymIdx - N x 1 transmitted combined symbol indices
%   rxSymIdx - N x 1 detected combined symbol indices
% Outputs:
%   ser - scalar, erroneous symbols / total symbols

    txSymIdx = txSymIdx(:);
    rxSymIdx = rxSymIdx(:);
    assert(numel(txSymIdx) == numel(rxSymIdx), ...
        'txSymIdx and rxSymIdx must have the same length.');

    ser = sum(txSymIdx ~= rxSymIdx) / numel(txSymIdx);
end
