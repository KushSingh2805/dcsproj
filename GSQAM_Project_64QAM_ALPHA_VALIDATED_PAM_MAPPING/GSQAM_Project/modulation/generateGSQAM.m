function gsqam = generateGSQAM(M_QAM, designEbN0_dB, varargin)
%GENERATEGSQAM Geometrically shaped QAM per the reference paper's
%truncated-Gaussian systematic design.
%
%   gsqam = generateGSQAM(M_QAM, designEbN0_dB) builds the shaped M_QAM
%   constellation by:
%     1. Optimizing the shaping parameter alpha to maximize the
%        constellation-constrained capacity (Eq. 3-6) of the PAM axis at
%        the given design Eb/N0 (this is the paper's Section III-C1
%        procedure, reproduced numerically).
%     2. Generating tentative shaped PAM points via Eq. (29):
%          aHat_k = erfinv( alpha * ((2k+1)/Mpam - 1) ), k=0..Mpam-1
%     3. Normalizing per Eq. (23) so E[X^2] = 1/2 per axis (see
%        normalizeShapedPAM.m for the exact derivation/traceability
%        note, since the source PDF's Eq. 23 OCR is corrupted).
%     4. Building the M_QAM constellation as two independent, identically
%        shaped PAM axes (Section III-C: "M2-QAM symbols consisting of
%        two identical M-PAM symbols"), using the SAME Gray-labeling
%        convention as generateConventionalQAM.m (buildQAMFromPAM.m) so
%        the bit-mapping logic is identical between schemes and only the
%        amplitude positions differ -> required for a fair comparison.
%
% Inputs:
%   M_QAM         - QAM constellation size (64, 256, 1024, ...)
%   designEbN0_dB - design-point Eb/N0 (dB) at which alpha is optimized.
%                   [PAPER + ASSUMPTION] see config.m: the paper only
%                   gives a concrete design point for 1024-QAM (32-PAM);
%                   the design points for 64/256-QAM are this project's
%                   own documented choice.
%   Name-Value:
%     'AlphaOverride' - if provided, skip optimization and use this
%                        alpha directly (useful for validation/plots
%                        against the paper's reported alpha=0.882 case)
%
% Outputs:
%   gsqam - struct, same shape as generateConventionalQAM's output, plus:
%     .alpha       - the (optimized or overridden) shaping parameter
%     .designEbN0_dB
%     .capacityAtAlpha - CM capacity (bits/PAM-dim) achieved at alpha

    p = inputParser;
    addParameter(p, 'AlphaOverride', []);
    parse(p, varargin{:});

    Mpam = sqrt(M_QAM);
    assert(abs(Mpam - round(Mpam)) < 1e-9, ...
        'M_QAM must be a perfect square (e.g. 64, 256, 1024).');
    Mpam = round(Mpam);
    bitsPerAxis = round(log2(Mpam));
    bitsPerSymbol = 2 * bitsPerAxis;

    % Convert project design Eb/N0 to the paper's QAM Es/N0:
    %   Es/N0 = Eb/N0 * log2(M_QAM).
    % The paper's capacity equations use Es/N0 for the QAM symbol while
    % the one-dimensional PAM axis has average energy Es/2. Therefore
    % computeCMCapacity is passed the QAM Es/N0 directly.
    EbN0_lin = 10^(designEbN0_dB/10);
    EsN0_QAM_lin = EbN0_lin * bitsPerSymbol;
    designEsN0_QAM_dB = 10*log10(EsN0_QAM_lin);

    if isempty(p.Results.AlphaOverride)
        [alphaStar, capAtStar] = optimizeAlpha(Mpam, designEsN0_QAM_dB, [0,1]);
    else
        alphaStar = p.Results.AlphaOverride;
        k = (0:Mpam-1)';
        aHatTmp = erfinv(alphaStar * ((2*k+1)/Mpam - 1));
        aTmp = normalizeShapedPAM(aHatTmp, Mpam);
        capAtStar = computeCMCapacity(aTmp, designEsN0_QAM_dB);
    end

    k = (0:Mpam-1)';
    aHat = erfinv( alphaStar * ((2*k + 1)/Mpam - 1) );   % Eq. (29)

    % Keep BOTH versions:
    %   aHat = raw GS-PAM mapping before energy normalization
    %   a    = normalized GS-PAM mapping used for simulation
    a = normalizeShapedPAM(aHat, Mpam);                  % Eq. (23) constraint

    gsqam.M_QAM = M_QAM;
    gsqam.Mpam = Mpam;
    gsqam.bitsPerAxis = bitsPerAxis;
    gsqam.pamLevelsRaw = aHat;              % RAW GS-PAM, before normalization
    gsqam.pamLevels = a;                     % normalized GS-PAM
    gsqam.constellation = buildQAMFromPAM(a, bitsPerAxis);
    gsqam.type = 'GS-QAM';
    gsqam.alpha = alphaStar;
    gsqam.designEbN0_dB = designEbN0_dB;
    gsqam.capacityAtAlpha = capAtStar;

    % Overall energy check (Test 3, Section 17)
    Es = mean(abs(gsqam.constellation).^2);
    assert(abs(Es - 1) < 1e-6, ...
        'GS-QAM average energy is %.6f, expected 1.', Es);

    % Uniqueness check (Test 2, Section 17)
    assert(numel(unique(gsqam.constellation)) == M_QAM, ...
        'GS-QAM constellation does not have %d unique points.', M_QAM);
end
