function CCM = computeCMCapacity(pamLevels, EsN0_dB)
%COMPUTECMCAPACITY Constellation-constrained capacity of a PAM set.
%   CCM = computeCMCapacity(pamLevels, EsN0_dB) implements Eq. (4)-(6) of
%   the reference paper:
%
%     CCM = m - E_Z[ psi(Z) ]                                 (Eq. 5)
%     psi(Z) = (1/M) * sum_k log2( sum_l exp( -(2*Z*(ak-al) +
%                                    (ak-al)^2) / (2*sigma^2) ) )   (Eq. 6)
%
%   where Z ~ N(0, sigma^2) is the AWGN sample. The expectation over Z is
%   evaluated with Gauss-Hermite quadrature (a standard, fast, and
%   numerically stable replacement for the paper's Monte-Carlo /
%   numerical integration approach to the same expectation).
%
% Inputs:
%   pamLevels - Mpam x 1 vector of PAM amplitudes, normalized in this
%               project so mean(a.^2) = Es_QAM/2 and Es_QAM = 1.
%   EsN0_dB   - scalar QAM Es/N0 in dB, matching the paper's convention.
%               The paper defines PAM average energy as Es/2 while the
%               SNR parameter is Es/N0 for the corresponding QAM symbol.
% Outputs:
%   CCM - constellation-constrained capacity in bits per PAM dimension

    a = pamLevels(:);
    Mpam = numel(a);
    m = log2(Mpam);

    % Paper convention: Es denotes the QAM symbol energy. The PAM axis
    % carries Es/2, but the SNR parameter is Es/N0. With this project's
    % normalization Es_QAM = 1, so N0 = 1/(Es/N0).
    EsQAM = 1;
    EsN0 = 10^(EsN0_dB/10);
    N0 = EsQAM / EsN0;
    sigma2 = N0 / 2;
    sigma = sqrt(sigma2);

    % Gauss-Hermite nodes/weights for integral over N(0,sigma^2):
    % E[f(Z)] = (1/sqrt(pi)) * sum_i w_i * f(sqrt(2)*sigma*x_i)
    nNodes = 40;
    [x, w] = gaussHermiteNodes(nNodes);

    Z = sqrt(2) * sigma * x;   % nNodes x 1

    % Pairwise amplitude differences (Mpam x Mpam)
    diffAA = a - a.';                          % (ak - al), Mpam x Mpam

    psiVals = zeros(numel(Z), 1);
    for zi = 1:numel(Z)
        z = Z(zi);
        expTerm = exp( -(2*z*diffAA + diffAA.^2) / (2*sigma2) ); % Mpam x Mpam
        innerSum = sum(expTerm, 2);            % sum over l, Mpam x 1
        psiVals(zi) = mean(log2(innerSum));    % (1/M) sum over k
    end

    Epsi = (1/sqrt(pi)) * sum(w .* psiVals);
    CCM = m - Epsi;
end

function [x, w] = gaussHermiteNodes(n)
%GAUSSHERMITENODES Nodes/weights for physicists' Gauss-Hermite quadrature.
% Golub-Welsch algorithm (no toolbox dependency).
    i = (1:n-1)';
    b = sqrt(i/2);
    J = diag(b,1) + diag(b,-1);
    [V, D] = eig(J);
    x = diag(D);
    [x, idx] = sort(x);
    V = V(:, idx);
    w = sqrt(pi) * (V(1,:).^2)';
end
