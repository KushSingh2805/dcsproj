function pointResult = runSimulationPoint(constellation, bitsPerAxis, channelName, EbN0_dB, cfg)
%RUNSIMULATIONPOINT One Monte Carlo point: modulate -> channel -> equalize
%-> detect -> BER/SER/EVM, for a single (constellation, channel, Eb/N0).
%
% [SPEC Section 10] Uses an adaptive sample count: starts at
% cfg.numSymbols, and if fewer than cfg.minBitErrors bit errors were
% observed, keeps adding batches (same size) up to a hard cap of
% 20x cfg.numSymbols, so that low-BER points at high Eb/N0 are not
% falsely reported as exactly zero due to insufficient samples. If the
% cap is hit with still-zero errors, the point is reported as
% "< 1/totalBits", i.e. BER/SER are reported as 0 but nSymbolsUsed shows
% exactly how many trials that zero is based on.
%
% Inputs:
%   constellation - M_QAM x 1 complex constellation (conventional or GS)
%   bitsPerAxis   - log2(Mpam)
%   channelName   - 'AWGN' | 'Rayleigh' | 'Rician'
%   EbN0_dB       - scalar, Eb/N0 in dB
%   cfg           - config() struct
% Outputs:
%   pointResult - struct with fields BER, SER, EVM_percent, EVM_dB,
%                 nSymbolsUsed, nBitErrorsUsed

    bitsPerSymbol = 2*bitsPerAxis;
    Es = mean(abs(constellation).^2);

    totalBits = 0; totalBitErrors = 0;
    totalSyms = 0; totalSymErrors = 0;
    sumSqErr = 0; sumSqIdeal = 0;

    batchSyms = cfg.numSymbols;
    maxSyms = 20 * cfg.numSymbols;
    symsDone = 0;

    while true
        txBits = randi([0 1], batchSyms*bitsPerSymbol, 1);
        [txSym, txIdx] = mapBitsToSymbols(txBits, constellation, bitsPerAxis);

        [rx, h] = applyChannel(txSym, channelName, EbN0_dB, bitsPerSymbol, Es, cfg.ricianK_dB);
        xHat = equalizeSignal(rx, h, channelName, cfg.minFadingMagnitude);

        [rxBits, rxIdx] = demapSymbols(xHat, constellation, bitsPerAxis);

        totalBits = totalBits + numel(txBits);
        totalBitErrors = totalBitErrors + sum(txBits ~= rxBits);
        totalSyms = totalSyms + numel(txIdx);
        totalSymErrors = totalSymErrors + sum(txIdx ~= rxIdx);
        sumSqErr = sumSqErr + sum(abs(xHat - txSym).^2);
        sumSqIdeal = sumSqIdeal + sum(abs(txSym).^2);

        symsDone = symsDone + batchSyms;

        if totalBitErrors >= cfg.minBitErrors || symsDone >= maxSyms
            break;
        end
    end

    pointResult.BER = totalBitErrors / totalBits;
    pointResult.SER = totalSymErrors / totalSyms;
    evmRMS = sqrt(sumSqErr / sumSqIdeal);
    pointResult.EVM_percent = 100 * evmRMS;
    pointResult.EVM_dB = 20*log10(evmRMS);
    pointResult.nSymbolsUsed = totalSyms;
    pointResult.nBitErrorsUsed = totalBitErrors;
end
