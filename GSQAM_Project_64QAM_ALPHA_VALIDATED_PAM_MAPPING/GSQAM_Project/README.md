# GS-QAM vs Conventional QAM — Project Status

**Reference paper:** Kurihara & Ochiai, "Design of Low-Complexity Coded
Modulation Employing High-Order QAM With Systematic Geometric
Constellation Shaping," IEEE Open J. Commun. Soc., vol. 5, 2024.

This is a staged build (per the project spec's own Section 24: validate
before proceeding). **All stages (1–16) are now implemented.** `main.m`
runs the full sweep and produces every deliverable listed in Section 25
of the spec.

**Current scope: 64-, 256-, and 1024-QAM.** The requested three modulation
orders are enabled in `config.m`. The full sweep uses the same architecture
for all three orders.

## What's implemented and how it maps to the paper

| File | Paper basis |
|---|---|
| `modulation/generateConventionalQAM.m` | Eq. (18)-(19): standard uniform PAM, built into M²-QAM |
| `modulation/generateGSQAM.m` | Eq. (29)-(30): truncated-Gaussian shaped PAM, `α∈[0,1]` |
| `modulation/normalizeShapedPAM.m` | Eq. (23) constraint `E[X²]=1/2` (exact scale factor **derived**, not copied — see file header, the source PDF's Eq. 23 OCR is corrupted) |
| `modulation/computeCMCapacity.m` | Eq. (3)-(6): constellation-constrained capacity, via Gauss-Hermite quadrature instead of the paper's Monte-Carlo integration (same expectation, different numerical method) |
| `modulation/optimizeAlpha.m` | Section III-C1's α-optimization procedure (paper does it via grid search in Fig. 5; here via `fminbnd` on the same objective) |
| `modulation/buildQAMFromPAM.m`, `grayMap.m`, `grayInverse.m` | Standard Gray labeling per PAM axis, applied identically to both schemes (Section IV-B1 notes BRGC is used for BICM in the paper) |
| `channels/awgnChannel.m` | Eq. (1) `y=x+n`, used here for an uncoded sweep (paper uses it for coded systems) |
| `channels/rayleighChannel.m`, `receiver/equalizeRayleigh.m` | **Not in the paper.** Spec Section 6B: flat Rayleigh, zero-forcing under perfect CSI |
| `channels/ricianChannel.m`, `receiver/equalizeRician.m` | **Not in the paper.** Spec Section 6C: flat Rician with configurable K (default 5 dB), zero-forcing under perfect CSI |
| `receiver/minimumDistanceDetector.m` | Optimal uncoded detector; paper itself uses an LLR/bit-metric approximation (Eq. 39-40) for its *coded* receivers, which doesn't apply here (see "Uncoded vs coded" below) |
| `metrics/calculateBER.m`, `calculateSER.m`, `calculateEVM.m` | Direct bit/symbol comparison (Sections 7-8); EVM (Section 9) is a user-specified metric not in the paper |
| `channels/applyChannel.m`, `receiver/equalizeSignal.m` | Dispatchers so `main.m`'s sweep loop doesn't repeat per-channel branching |
| `modulation/runSimulationPoint.m` | Standalone single-scheme Monte Carlo point; retained for validation/reuse |
| `runPairedSimulationPoint.m` | **Fair paired** Conventional-vs-GS Monte Carlo point: same bits, fading, noise, and sample count for both schemes |
| `plotting/*.m` | Stages 13-14: ideal + received constellation plots, BER/SER/EVM vs Eb/N0 (one figure per channel, per Section 14) |
| `analysis/generateComparisonTable.m` | Stage 15: BER/SER/EVM at a representative Eb/N0, with "reduction" vs "degradation" wording chosen strictly from the sign of the actual result, never assumed |
| `analysis/crossoverAnalysis.m` | Stage 16: reads winner and crossover Eb/N0 directly off the simulated arrays; a "crossover" requires GS-QAM to keep winning at every later point, not just cross once, so Monte Carlo noise doesn't get reported as a real trend |
| `main.m` | Stages 9-16: runs everything above end to end and saves all outputs |

## Key deviations from the paper (documented, not hidden)

1. **α is not a formula of M.** The paper finds it by numerically
   maximizing mutual information *at one target SNR/spectral efficiency*
   per case; it gives a concrete example only for 32-PAM/1024-QAM
   (α*=0.882 at Es/N0=26.5 dB). The design Eb/N0 used to optimize α for
   64-QAM and 256-QAM in `config.m` is **this project's own choice**, not
   from the paper — clearly marked `[ASSUMPTION]` in `config.m`.
2. **Uncoded vs. coded.** The paper's reported performance gains
   (Figs. 13-14) are for **coded** MLC/MSD and BICM with turbo codes.
   This project measures **uncoded** BER/SER/EVM (per your request), which
   is a different, and generally smaller, manifestation of the shaping
   gain. `config.m` sets `codedSystem = false` and documents this.
3. **Rayleigh/Rician fading are not in the paper at all** — the paper
   only simulates AWGN. These channels (to be added in the next stage)
   are entirely this project's extension.
4. **EVM** is not a paper metric — your own addition, standard formula.
5. **Results struct layout.** Section 12's spec used numeric struct-array
   indexing (`results(M_index).channel(channel_index)...`). This project
   uses dynamic field names instead (`results.M1024.Rayleigh.gsqam.BER`)
   — same information, but addressed by name rather than index, which is
   less error-prone in MATLAB and easier to inspect interactively. If you
   need the numeric-index form for something downstream, it's a
   mechanical conversion and I can add it.
6. `plotMetricCurves.m` uses `sgtitle`, which requires MATLAB R2018b or
   later. If you're on an older release, tell me and I'll swap it for an
   `annotation`-based title instead.

## How to run

```matlab
cd GSQAM_Project
validate_stage1   % Tests 1-4: constellation structure/energy/round-trip
validate_stage2   % Tests 5-7: AWGN sanity, Rayleigh worse than AWGN, Rician K trend
main              % full sweep: BER/SER/EVM, plots, tables, crossover analysis
```

Run the two validation scripts first and confirm every check passes — do
not run `main.m` until they do (Section 24 of the spec). `main.m` will
take a while: it's `3 modulation orders × 3 channels × 2 schemes ×
numel(cfg.EbN0_dB_range)` paired Monte Carlo points. Each paired point starts
at `cfg.numSymbols` and adds common batches until both schemes have at least
`cfg.minBitErrors` bit errors, capped at `cfg.maxSymbolsPerPoint`. This keeps
the two schemes on identical random trials and prevents avoidable Monte-Carlo
variation from being interpreted as shaping gain. If it's too slow for a first pass, shrink
`cfg.EbN0_dB_range` or `cfg.numSymbols` in `config.m`; widen them again
once you're happy with the pipeline, for the final numbers.

**I have not been able to execute any of this in MATLAB myself** — please
run all three scripts and tell me what you see, especially:
- did `main.m` run to completion without errors,
- do the BER/SER curves look sane (monotonically improving with Eb/N0,
  no NaN/Inf, Rayleigh clearly worse than AWGN),
- what the printed comparison table and crossover analysis actually say.

`main.m` produces, per Section 25 of the spec: ideal + received
constellation plots, BER/SER/EVM vs Eb/N0 (one figure per channel),
`results/comparison_table.csv`, `results/full_simulation_results.mat`,
`results/crossover_summary.mat`, and the printed crossover/winner
analysis in the console — everything needed to answer the project's
central question **from the simulated numbers, not from an assumption**.

## Fair paired Monte-Carlo comparison (updated)

The full sweep now uses `runPairedSimulationPoint.m`. For every Eb/N0 and
channel, conventional QAM and GS-QAM receive the **same transmitted bit
stream, same fading coefficients, and same AWGN samples**. Both schemes
also use the same number of symbols per point. This paired design removes
avoidable Monte-Carlo differences from the Conventional-vs-GS comparison.

This matters especially for the project's EVM definition. Because both
constellations are normalized to the same average symbol energy and the
receiver uses perfect-CSI zero-forcing equalization on fading channels,

`xHat - x = n/h`

for Rayleigh/Rician and `xHat - x = n` for AWGN. Therefore post-equalization
EVM is primarily a **channel/noise impairment metric**, not a direct measure
of geometric-shaping gain. With identical paired noise/fading, Conventional
and GS-QAM EVM curves may become nearly identical; that is expected and is
more scientifically defensible than differences caused by independent random
trials. BER and SER are the metrics that should carry most of the direct
constellation-shaping comparison in this uncoded project.

The project scope is restored to the requested **64-, 256-, and 1024-QAM**.
The alpha design Eb/N0 values are 18 dB (64-QAM) and 22 dB (256-QAM) as
project engineering choices, while 26.5 dB for 1024-QAM/32-PAM follows the
paper's worked design point. These choices are documented in `config.m`.


### Paper-reference validation
Run `validate_paper_alpha` to verify the CM-capacity optimizer against the paper's 32-PAM reference at Es/N0 = 26.50 dB. The expected optimum is alpha ≈ 0.882 and CCM ≈ 4.262 bits/dimension.


### PAM mapping visualization

The project now stores and plots both the raw and normalized PAM mappings:
- `pamLevelsRaw`: PAM amplitudes before energy normalization.
- `pamLevels`: PAM amplitudes after normalization, used for QAM simulation.

`main.m` calls `plotPAMMappings(results,cfg)` and produces four rows:
1. Raw conventional PAM
2. Raw GS-PAM
3. Normalized conventional PAM
4. Normalized GS-PAM

This makes the geometric redistribution caused by `alpha` visible separately from the common average-energy normalization.
