function a = normalizeShapedPAM(aHat, Mpam)
%NORMALIZESHAPEDPAM Energy-normalize tentative shaped PAM points.
%   a = normalizeShapedPAM(aHat, Mpam) enforces the constraint stated in
%   the paper for Eq. (23): the normalized constellation must satisfy
%   E[X^2] = 1/2 per PAM axis (so that combined I/Q QAM energy Es = 1).
%
% [NOTE ON PAPER TRACEABILITY] The OCR'd text of Eq. (23) in the source
% PDF is corrupted ("ak  aˆk # 2 M M−1 k=0 aˆ2 k"). Rather than guess the
% exact typesetting, the scale factor below is DERIVED to satisfy the
% paper's own stated constraint text ("the resulting constellation
% {a0,...,aM-1} satisfies E[X^2] = 1/2"):
%
%   want:  (1/Mpam) * sum(a_k^2) = 1/2
%   with:  a_k = c * aHat_k
%   =>     c = sqrt( Mpam / (2 * sum(aHat_k.^2)) )
%
% This is verified numerically below (Test 3, Section 17 of the spec).
%
% Inputs:
%   aHat - Mpam x 1 tentative (unnormalized) shaped PAM points, Eq. (29)
%   Mpam - PAM constellation size
% Outputs:
%   a - Mpam x 1 normalized PAM points with E[X^2] = 1/2

    aHat = aHat(:);
    S = sum(aHat.^2);
    c = sqrt(Mpam / (2*S));
    a = c * aHat;

    Eax = mean(a.^2);
    assert(abs(Eax - 0.5) < 1e-6, ...
        'Shaped PAM axis energy is %.6f, expected 0.5.', Eax);
end
