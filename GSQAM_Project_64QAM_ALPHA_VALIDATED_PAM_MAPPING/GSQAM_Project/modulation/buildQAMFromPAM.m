function constellation = buildQAMFromPAM(pamLevels, bitsPerAxis)
%BUILDQAMFROMPAM Build an M^2-QAM constellation vector from PAM levels.
%   constellation = buildQAMFromPAM(pamLevels, bitsPerAxis) is the shared
%   bit<->symbol convention used for BOTH conventional and GS-QAM, which
%   is what makes the comparison fair (same labeling logic, only the
%   amplitude vector pamLevels differs between the two schemes).
%
% Convention: a combined symbol index s in [0, M_QAM-1] is split into two
% bitsPerAxis-bit fields: the upper field is the Gray-coded I index, the
% lower field is the Gray-coded Q index. Each Gray index is inverted to
% a natural PAM index (0..Mpam-1) via grayInverse.m, which selects the
% corresponding entry of pamLevels (in natural spatial order, as returned
% by generateConventionalQAM.m / generateGSQAM.m).
%
% Inputs:
%   pamLevels   - Mpam x 1 (or 1 x Mpam) vector of PAM amplitudes in
%                 natural spatial order (ascending amplitude)
%   bitsPerAxis - log2(Mpam)
% Outputs:
%   constellation - M_QAM x 1 complex vector, constellation(s+1) is the
%                   symbol for combined index s = 0..M_QAM-1

    pamLevels = pamLevels(:);
    Mpam = numel(pamLevels);
    M_QAM = Mpam^2;

    s = (0:M_QAM-1)';
    grayI = bitshift(s, -bitsPerAxis);              % upper bits
    grayQ = bitand(s, (2^bitsPerAxis - 1));          % lower bits

    kI = grayInverse(grayI, bitsPerAxis);
    kQ = grayInverse(grayQ, bitsPerAxis);

    constellation = pamLevels(kI + 1) + 1j * pamLevels(kQ + 1);
end
