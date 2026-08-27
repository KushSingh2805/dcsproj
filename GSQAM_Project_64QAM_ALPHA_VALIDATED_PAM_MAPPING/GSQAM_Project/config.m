function cfg = config()
%CONFIG Central configuration for the GS-QAM vs conventional QAM project.
%
% Reference paper:
%   Kurihara & Ochiai, "Design of Low-Complexity Coded Modulation Employing
%   High-Order QAM With Systematic Geometric Constellation Shaping,"
%   IEEE Open Journal of the Communications Society, vol. 5, 2024.
%
% Every field below is tagged as either:
%   [PAPER]       - value/method taken directly from the paper
%   [ASSUMPTION]  - not specified in the paper for this exact case; a
%                   documented engineering choice was made instead.
%
% Outputs:
%   cfg - struct with all simulation parameters

    %% Modulation orders under test -----------------------------------
    % 64-QAM = 8^2, 256-QAM = 16^2, 1024-QAM = 32^2  --> Mpam = [8 16 32]
    % [PAPER] The paper builds M^2-QAM from two independent, identically
    % shaped M-PAM axes (Section III-C: "we employ M2-QAM symbols
    % consisting of the two identical M-PAM symbols"). 1024-QAM/32-PAM is
    % the paper's own worked example (alpha* = 0.882 at Eb/N0 design
    % point). 64-QAM and 256-QAM are not explicitly worked in the paper,
    % but fit the identical M^2 = Mpam^2 framework.
    % [PROJECT SCOPE] Compare all three requested modulation orders.
    cfg.M_QAM  = 64;
    cfg.M_PAM  = sqrt(cfg.M_QAM);
    cfg.bitsPerSymbol = log2(cfg.M_QAM);
    cfg.bitsPerPAM    = log2(cfg.M_PAM);

    %% Shaping parameter design point ----------------------------------
    % [PAPER] alpha is NOT a closed-form function of M. It is obtained by
    % numerically maximizing the constellation-constrained capacity
    % (Eq. 3-6 of the paper) at one target design SNR (Es/N0), then the
    % resulting constellation is FROZEN and used for the entire BER/SER
    % sweep (this mirrors exactly how the paper generated its own BER
    % figures, e.g. Fig. 13/14, using a single alpha* found at one design
    % SNR of 26.5 dB for 32-PAM).
    %
    % [ASSUMPTION] The paper only gives a concrete design SNR for
    % 32-PAM/1024-QAM (26.50 dB, targeting a coded spectral efficiency of
    % 4.250 bits/dim with an outer code rate ~0.85). It gives no example
    % for 8-PAM/64-QAM or 16-PAM/256-QAM. Because this project is UNCODED
    % (see note below), we cannot reuse the paper's "target coded rate"
    % logic directly. Instead we pick a design Es/N0 per M that sits in
    % the paper's own reported operating region (an SNR where standard
    % QAM already achieves a reasonably low uncoded SER), and hold it
    % fixed. These numbers are engineering choices, not paper values,
    % and are called out again in the README.
    cfg.designEbN0_dB = 18;   % dB; 64-QAM project design point

    %% Uncoded vs coded — explicit deviation note -----------------------
    % [ASSUMPTION / DEVIATION] The paper's headline performance results
    % (Figs. 13-14, Section V-VI) are for CODED systems: MLC/MSD and BICM
    % with rate-compatible punctured turbo codes. This project instead
    % measures UNCODED bit/symbol error rate and EVM, per the user's
    % request. Shaping gain is fundamentally a mutual-information gain;
    % its effect on uncoded BER is smaller and not guaranteed to be
    % positive at every SNR. This is documented, not hidden.
    cfg.codedSystem = false;

    %% Alpha search range -------------------------------------------------
    cfg.alphaSearchRange = [0, 1];   % [PAPER] alpha in [0,1], Eq. (30)

    %% Eb/N0 sweep for BER/SER/EVM curves --------------------------------
    % [ASSUMPTION] Not specified by the paper for an uncoded sweep;
    % extended range chosen so 1024-QAM shows a usable waterfall.
    cfg.EbN0_dB_range = 0:2:30;

    %% Channel models -----------------------------------------------------
    % [DEVIATION] AWGN only is in the paper. Rayleigh/Rician flat fading
    % with perfect CSI at the receiver are the user's own extension.
    cfg.channels = {'AWGN', 'Rayleigh', 'Rician'};
    cfg.ricianK_dB = 5;   % [ASSUMPTION] configurable, default 5 dB

    %% Monte Carlo parameters ----------------------------------------------
    cfg.numSymbols   = 1e5;   % base symbols per paired Monte-Carlo batch
    cfg.minBitErrors = 100;   % require both schemes to reach this count
    cfg.maxSymbolsPerPoint = 20 * cfg.numSymbols;
    cfg.rngSeed = 42;

    %% Numerical stability tolerances --------------------------------------
    cfg.energyTolerance = 1e-6;   % for mean(|x|^2) ≈ 1 assertions
    cfg.minFadingMagnitude = 1e-6; % floor to avoid unstable equalization
end
