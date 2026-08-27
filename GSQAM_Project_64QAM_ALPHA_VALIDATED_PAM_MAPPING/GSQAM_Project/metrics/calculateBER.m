function ber = calculateBER(txBits, rxBits)
%CALCULATEBER Bit error rate from actual transmitted vs recovered bits.
%   ber = calculateBER(txBits, rxBits)
%
% [SPEC Section 7] Computed by direct comparison of the transmitted and
% recovered bit streams — NOT approximated from symbol error rate.
%
% Inputs:
%   txBits - N x 1 transmitted bits (0/1)
%   rxBits - N x 1 recovered bits (0/1), same length as txBits
% Outputs:
%   ber - scalar, erroneous bits / total bits

    txBits = txBits(:);
    rxBits = rxBits(:);
    assert(numel(txBits) == numel(rxBits), ...
        'txBits and rxBits must have the same length.');

    ber = sum(txBits ~= rxBits) / numel(txBits);
end
