function symIdxHat = minimumDistanceDetector(rxSymbols, constellation)
%MINIMUMDISTANCEDETECTOR Minimum-Euclidean-distance symbol detection.
%   symIdxHat = minimumDistanceDetector(rxSymbols, constellation)
%
% Implements: symIdxHat = argmin_k |y - constellation(k)|^2
%
% [PAPER NOTE] The paper's own receivers use an LLR/bit-metric
% approximation (Eq. 39-40) for coded decoding, not exhaustive minimum
% distance. Since this project is uncoded (see README), exhaustive
% minimum-Euclidean-distance detection against the actual constellation
% in use is the correct optimal uncoded detector, per the spec's
% Section 8 instruction. It is applied identically to the standard and
% shaped constellations — never mixing decision regions between schemes.
%
% Inputs:
%   rxSymbols     - Nsym x 1 complex received/equalized symbols
%   constellation - M_QAM x 1 complex constellation (0-indexed
%                   convention: constellation(k+1) <-> combined index k)
% Outputs:
%   symIdxHat - Nsym x 1 detected combined symbol index (0..M_QAM-1)

    rxSymbols = rxSymbols(:);
    dist2 = abs(rxSymbols - constellation(:).').^2;   % Nsym x M_QAM
    [~, idx0] = min(dist2, [], 2);
    symIdxHat = idx0 - 1;
    assert(all(isfinite(symIdxHat)), 'Detector produced non-finite symbol indices.');
    assert(all(symIdxHat >= 0 & symIdxHat < numel(constellation)), ...
        'Detector produced an out-of-range symbol index. Check that the project receiver detector is on the MATLAB path.');
end
