# Modifications made

1. **main.m**
   - Uses `runPairedSimulationPoint` for every Conventional-vs-GS comparison.
   - Restores the requested 64/256/1024-QAM sweep through `config.m`.

2. **runPairedSimulationPoint.m** (new)
   - Same random bits for Conventional and GS-QAM.
   - Same AWGN realization.
   - Same Rayleigh/Rician fading coefficients.
   - Same number of symbols per Eb/N0 point.
   - Stops only when both schemes have enough bit errors or the common cap is reached.

3. **config.m**
   - Enables 64-, 256-, and 1024-QAM.
   - Uses design Eb/N0 = 18, 22, and 26.5 dB respectively; the first two are project choices and 26.5 dB follows the paper's 32-PAM example.
   - Adds `maxSymbolsPerPoint`.

4. **plotting/plotReceivedConstellations.m**
   - Uses paired random bits/noise/fading for the Conventional and GS received-constellation comparison.

5. **README.md**
   - Documents the paired Monte-Carlo method and explains why post-equalization EVM can be nearly identical between the two constellations.

## Important interpretation

With perfect-CSI zero-forcing equalization, the residual error is `n/h` for fading
channels and `n` for AWGN. Since both constellations are normalized to the same
average symbol energy, EVM is primarily a channel/noise metric in this setup.
BER/SER are therefore the main direct performance metrics for geometric shaping.
