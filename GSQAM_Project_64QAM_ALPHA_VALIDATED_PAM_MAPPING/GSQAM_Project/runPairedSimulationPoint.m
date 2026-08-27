function pairedResult = runPairedSimulationPoint(convConstellation, gsConstellation, bitsPerAxis, channelName, EbN0_dB, cfg)
%RUNPAIREDSIMULATIONPOINT Fair paired Monte-Carlo point for Conventional vs GS-QAM.
%   Both schemes use the SAME transmitted bit stream, SAME channel fading
%   realization, and SAME AWGN realization for every batch. This removes
%   avoidable Monte-Carlo differences from the comparison.
%
%   The two constellations are both normalized to Es ~= 1, so the same N0
%   is used for both schemes. Under the project's post-equalization EVM
%   definition, paired EVM is expected to be essentially identical because
%   the residual error is n/h for fading channels (and n for AWGN).
%
%   Outputs:
%     pairedResult.conventional / .gsqam each contain the same fields as
%     runSimulationPoint.m, plus nSymbolsUsed and nBitErrorsUsed.

    assert(numel(convConstellation) == numel(gsConstellation), ...
        'Conventional and GS constellations must have the same M.');

    bitsPerSymbol = 2*bitsPerAxis;
    EsConv = mean(abs(convConstellation).^2);
    EsGS   = mean(abs(gsConstellation).^2);
    assert(abs(EsConv - EsGS) < 1e-6, ...
        'Conventional and GS constellations must have equal average energy.');

    totalBits = 0;
    totalBitErrC = 0; totalBitErrG = 0;
    totalSymErrC = 0; totalSymErrG = 0;
    totalSyms = 0;
    sumSqErrC = 0; sumSqErrG = 0;
    sumSqIdealC = 0; sumSqIdealG = 0;

    batchSyms = cfg.numSymbols;
    maxSyms = cfg.maxSymbolsPerPoint;
    symsDone = 0;

    while true
        % SAME source bits for both modulation schemes.
        txBits = randi([0 1], batchSyms*bitsPerSymbol, 1);

        [txSymC, txIdxC] = mapBitsToSymbols(txBits, convConstellation, bitsPerAxis);
        [txSymG, txIdxG] = mapBitsToSymbols(txBits, gsConstellation, bitsPerAxis);

        % SAME channel realization/noise for both schemes.
        [rxC, rxG, h] = applyPairedChannel(txSymC, txSymG, channelName, ...
            EbN0_dB, bitsPerSymbol, EsConv, cfg.ricianK_dB);

        xHatC = equalizeSignal(rxC, h, channelName, cfg.minFadingMagnitude);
        xHatG = equalizeSignal(rxG, h, channelName, cfg.minFadingMagnitude);

        [rxBitsC, rxIdxHatC] = demapSymbols(xHatC, convConstellation, bitsPerAxis);
        [rxBitsG, rxIdxHatG] = demapSymbols(xHatG, gsConstellation, bitsPerAxis);

        totalBits = totalBits + numel(txBits);
        totalBitErrC = totalBitErrC + sum(txBits ~= rxBitsC);
        totalBitErrG = totalBitErrG + sum(txBits ~= rxBitsG);

        totalSymErrC = totalSymErrC + sum(txIdxC ~= rxIdxHatC);
        totalSymErrG = totalSymErrG + sum(txIdxG ~= rxIdxHatG);
        totalSyms = totalSyms + numel(txIdxC);

        sumSqErrC = sumSqErrC + sum(abs(xHatC - txSymC).^2);
        sumSqErrG = sumSqErrG + sum(abs(xHatG - txSymG).^2);
        sumSqIdealC = sumSqIdealC + sum(abs(txSymC).^2);
        sumSqIdealG = sumSqIdealG + sum(abs(txSymG).^2);

        symsDone = symsDone + batchSyms;

        % Stop when BOTH schemes have enough errors, or the common trial
        % budget is exhausted. This keeps the sample count identical.
        if (totalBitErrC >= cfg.minBitErrors && totalBitErrG >= cfg.minBitErrors) || ...
                symsDone >= maxSyms
            break;
        end
    end

    pairedResult.conventional = makePointResult( ...
        totalBitErrC, totalSymErrC, totalBits, totalSyms, sumSqErrC, sumSqIdealC);
    pairedResult.gsqam = makePointResult( ...
        totalBitErrG, totalSymErrG, totalBits, totalSyms, sumSqErrG, sumSqIdealG);
    pairedResult.sharedN0Trials = totalSyms;
end

function [rxC, rxG, h] = applyPairedChannel(txC, txG, channelName, EbN0_dB, bitsPerSymbol, Es, ricianK_dB)
    txC = txC(:); txG = txG(:);
    assert(numel(txC) == numel(txG), 'Paired symbol vectors must have equal length.');
    N = numel(txC);

    EbN0_lin = 10^(EbN0_dB/10);
    N0 = Es / (EbN0_lin * bitsPerSymbol);
    n = sqrt(N0/2) * (randn(N,1) + 1j*randn(N,1));

    switch channelName
        case 'AWGN'
            h = [];
            rxC = txC + n;
            rxG = txG + n;
        case 'Rayleigh'
            h = (randn(N,1) + 1j*randn(N,1)) / sqrt(2);
            rxC = h .* txC + n;
            rxG = h .* txG + n;
        case 'Rician'
            K_lin = 10^(ricianK_dB/10);
            sLOS = sqrt(K_lin/(K_lin+1));
            sigma = sqrt(1/(2*(K_lin+1)));
            h = sLOS + sigma*(randn(N,1) + 1j*randn(N,1));
            rxC = h .* txC + n;
            rxG = h .* txG + n;
        otherwise
            error('Unknown channel: %s', channelName);
    end
end

function r = makePointResult(bitErr, symErr, totalBits, totalSyms, sumSqErr, sumSqIdeal)
    r.BER = bitErr / totalBits;
    r.SER = symErr / totalSyms;
    evmRMS = sqrt(sumSqErr / sumSqIdeal);
    r.EVM_percent = 100 * evmRMS;
    r.EVM_dB = 20*log10(evmRMS);
    r.nSymbolsUsed = totalSyms;
    r.nBitErrorsUsed = bitErr;
end
