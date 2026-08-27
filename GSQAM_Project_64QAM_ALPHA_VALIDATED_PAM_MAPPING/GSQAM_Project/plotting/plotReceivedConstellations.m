function plotReceivedConstellations(results, cfg, repEbN0_dB)
%PLOTRECEIVEDCONSTELLATIONS Paired received/equalized constellations.
%   Conventional and GS-QAM use the SAME bits, fading realization and
%   noise realization so visual differences are attributable to geometry.

    M = cfg.M_QAM(end);
    fieldName = sprintf('M%d', M);
    convQ = results.(fieldName).conventional;
    gsQ = results.(fieldName).gsqam;

    nSym = 3000;
    bitsPerSymbol = 2*convQ.bitsPerAxis;
    Es = mean(abs(convQ.constellation).^2);

    txBits = randi([0 1], nSym*bitsPerSymbol, 1);
    [txSymC, ~] = mapBitsToSymbols(txBits, convQ.constellation, convQ.bitsPerAxis);
    [txSymG, ~] = mapBitsToSymbols(txBits, gsQ.constellation, gsQ.bitsPerAxis);

    % Shared realization for the two schemes.
    EbN0_lin = 10^(repEbN0_dB/10);
    N0 = Es/(EbN0_lin*bitsPerSymbol);
    n = sqrt(N0/2)*(randn(nSym,1)+1j*randn(nSym,1));

    figure('Name', sprintf('Received Constellations @ Eb/N0=%g dB (%d-QAM)', repEbN0_dB, M), ...
           'Position', [50 50 1400 900]);

    channelList = cfg.channels;
    for ci = 1:numel(channelList)
        channelName = channelList{ci};

        switch channelName
            case 'AWGN'
                h = [];
                rxC = txSymC + n;
                rxG = txSymG + n;
            case 'Rayleigh'
                h = (randn(nSym,1)+1j*randn(nSym,1))/sqrt(2);
                rxC = h.*txSymC+n;
                rxG = h.*txSymG+n;
            case 'Rician'
                K = 10^(cfg.ricianK_dB/10);
                sLOS = sqrt(K/(K+1));
                sigma = sqrt(1/(2*(K+1)));
                h = sLOS + sigma*(randn(nSym,1)+1j*randn(nSym,1));
                rxC = h.*txSymC+n;
                rxG = h.*txSymG+n;
            otherwise
                error('Unknown channel: %s', channelName);
        end

        xHatC = equalizeSignal(rxC, h, channelName, cfg.minFadingMagnitude);
        xHatG = equalizeSignal(rxG, h, channelName, cfg.minFadingMagnitude);

        subplotIdx = (ci-1)*2 + 1;
        subplot(numel(channelList), 2, subplotIdx);
        plot(real(xHatC), imag(xHatC), '.', 'MarkerSize', 3, 'Color', [0.3 0.3 0.3]);
        hold on;
        plot(real(convQ.constellation), imag(convQ.constellation), 'r.', 'MarkerSize', 12);
        hold off; grid on; axis equal;
        xlabel('I'); ylabel('Q'); title(sprintf('%s - Conventional', channelName));

        subplotIdx = (ci-1)*2 + 2;
        subplot(numel(channelList), 2, subplotIdx);
        plot(real(xHatG), imag(xHatG), '.', 'MarkerSize', 3, 'Color', [0.3 0.3 0.3]);
        hold on;
        plot(real(gsQ.constellation), imag(gsQ.constellation), 'r.', 'MarkerSize', 12);
        hold off; grid on; axis equal;
        xlabel('I'); ylabel('Q'); title(sprintf('%s - GS-QAM', channelName));
    end
end
