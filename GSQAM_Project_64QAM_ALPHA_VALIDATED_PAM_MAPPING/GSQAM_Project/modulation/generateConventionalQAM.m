function qam = generateConventionalQAM(M_QAM)
%GENERATECONVENTIONALQAM Standard uniformly-spaced square M-QAM.
%   qam = generateConventionalQAM(M_QAM) builds an M_QAM-point square QAM
%   constellation from two independent uniformly-spaced PAM axes.
%
% Based on Eq. (18)-(19) of the reference paper (standard PAM):
%   a_k = (-Mpam + 1 + 2k) * d ,   k = 0 .. Mpam-1
%   d   = sqrt( 3 / (2*(Mpam^2 - 1)) )
% This normalization already gives E[X^2] = 1/2 per PAM axis, so the
% combined QAM symbol energy is exactly E[|s|^2] = 1 (paper convention,
% Es = 1). We verify this with an assertion rather than assuming it.
%
% Bit labeling: standard Gray code per axis (grayMap.m), applied to the
% natural spatial order of the PAM points (index k = 0 lowest amplitude
% to k = Mpam-1 highest amplitude). This is the conventional Gray-QAM
% mapping.
%
% Inputs:
%   M_QAM - QAM constellation size, must be a perfect square power of 4
%           (e.g. 64, 256, 1024)
% Outputs:
%   qam - struct with fields:
%     .M_QAM        - constellation size
%     .Mpam         - sqrt(M_QAM)
%     .bitsPerAxis  - log2(Mpam)
%     .pamLevels    - 1 x Mpam vector of PAM amplitudes, natural order
%     .constellation- M_QAM x 1 complex vector, indexed by symbol index
%                     0..M_QAM-1 where symbol = grayIdxToAmp(I) +
%                     1j*grayIdxToAmp(Q) (see mapBitsToSymbols.m for the
%                     exact bit<->index convention used at TX/RX)
%     .type         - 'conventional'

    Mpam = sqrt(M_QAM);
    assert(abs(Mpam - round(Mpam)) < 1e-9, ...
        'M_QAM must be a perfect square (e.g. 64, 256, 1024).');
    Mpam = round(Mpam);
    bitsPerAxis = log2(Mpam);
    assert(abs(bitsPerAxis - round(bitsPerAxis)) < 1e-9, ...
        'sqrt(M_QAM) must be a power of 2.');
    bitsPerAxis = round(bitsPerAxis);

    k = (0:Mpam-1)';

    % RAW conventional PAM mapping before normalization:
    %   a_raw(k) = -Mpam+1+2k
    % This is the familiar equally spaced odd-integer PAM grid.
    aRaw = (-Mpam + 1 + 2*k);

    % Normalized conventional PAM mapping:
    %   d = sqrt(3/(2*(Mpam^2-1)))
    %   a = aRaw*d
    d = sqrt(3 / (2*(Mpam^2 - 1)));          % Eq. (19)
    a = aRaw * d;                            % Eq. (18)

    % Sanity check: E[X^2] = 1/2 per axis by construction of standard QAM
    Eax = mean(a.^2);
    assert(abs(Eax - 0.5) < 1e-6, ...
        'Standard PAM axis energy is %.6f, expected 0.5.', Eax);

    qam.M_QAM = M_QAM;
    qam.Mpam = Mpam;
    qam.bitsPerAxis = bitsPerAxis;
    qam.pamLevelsRaw = aRaw;                 % RAW PAM, before normalization
    qam.pamLevels = a;                        % normalized PAM
    qam.constellation = buildQAMFromPAM(a, bitsPerAxis);
    qam.type = 'conventional';

    % Final overall energy check (Test 3 of Section 17)
    Es = mean(abs(qam.constellation).^2);
    assert(abs(Es - 1) < 1e-6, ...
        'Conventional QAM average energy is %.6f, expected 1.', Es);
end
