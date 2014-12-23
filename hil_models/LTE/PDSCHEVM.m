function finalEVM = PDSCHEVM(rmc,cec,rxWaveform)
   
    % Compute some parameters.
    dims = lteOFDMInfo(rmc);
    samplesPerSubframe = dims.SamplingRate/1000;
    nSubframes = floor(size(rxWaveform, 1)/samplesPerSubframe);
    nFrames = floor(nSubframes/10);
    W = getEVMWindow(rmc);
    if (mod(W,2)==0)
        alpha = 0;
    else
        alpha = 1;
    end
    
    cpLength = 144*double(dims.Nfft)/2048;  
    
    if (isfield(rmc,'CyclicPrefix'))
        if strcmp(rmc.CyclicPrefix,'Extended')
            cpLength = 512*double(dims.Nfft)/2048;
        end
    end   
    
    gridDims = lteResourceGridSize(rmc);
    L = gridDims(2);    
   
    % Perform IQ offset correction
    iqoffset = mean(rxWaveform);
    rxWaveform = rxWaveform-repmat(iqoffset, size(rxWaveform, 1), 1);
    
    % Pad on the tail to allow for CP correlation.
    rxWaveform = [rxWaveform; zeros(dims.Nfft, size(rxWaveform, 2))];          
       
    % For each subframe:
    rxGridLow = [];
    rxGridHigh = [];
    frameEVM = repmat(lteEVM(NaN), 1, nFrames);
    delta_f_tilde_old = 0.0;
    p = 1;
    for i = 0:nSubframes-1
                               
        % Extract this subframe.
        rxSubframe = rxWaveform( ...
            i*samplesPerSubframe+(1:(samplesPerSubframe+dims.Nfft)), :);

        % Do frequency offset estimation and correction for this subframe
        delta_f_tilde = lteFrequencyOffset(rmc, rxSubframe, 0);
        rxSubframeFreqCorrected = lteFrequencyCorrect( ...
            rmc, rxSubframe(1:samplesPerSubframe, :), delta_f_tilde);
        
        % Ensure phase continuity between frequency corrected outputs 
        t = size(rxSubframeFreqCorrected, 1)/dims.SamplingRate;
        p = p*exp(-1i*2*pi*delta_f_tilde_old*t);
        rxSubframeFreqCorrected = rxSubframeFreqCorrected.*p;        
        delta_f_tilde_old = delta_f_tilde;

        % For low edge EVM and high edge EVM:
        for e = 1:2

            % Compute EVM window edge position and perform OFDM
            % demodulation. The standard defines window position in
            % samples, the LTE System Toolbox(TM) requires it as a fraction
            % of the cyclic prefix length.
            if (e==1)
                cpFraction = (cpLength/2 + alpha - floor(W/2))/cpLength;                
                 rxGridLow = [rxGridLow lteOFDMDemodulate( ...
                     rmc, rxSubframeFreqCorrected, cpFraction)]; %#ok
            else
                cpFraction = (cpLength/2 + floor(W/2))/cpLength;                
                rxGridHigh = [rxGridHigh lteOFDMDemodulate( ...
                    rmc, rxSubframeFreqCorrected, cpFraction)]; %#ok
            end

        end

    end
                
    % Channel estimation. 
    % Allow channel estimates to be processed in blocks of 10 subframes if
    % TestEVM channel estimate is used as per TS36.141 Annex F.3.4
    if strcmp(cec.PilotAverage,'TestEVM')
        nsfBlk = 10;
    else
        nsfBlk = nSubframes;
    end
    nBlocks = ceil(nSubframes/nsfBlk);

    HestLow = [];
    HestHigh = [];
    for i = 0:(nBlocks-1)
        % Index of symbols within current block. If a symbol index exceeds
        % the length of the received grid remove it.
        symIdx = i*L*nsfBlk+(1:(L*nsfBlk));
        symIdx(symIdx>size(rxGridLow, 2)) = [];
        
        HestLowBlk = lteDLChannelEstimate(rmc, cec, rxGridLow(:, symIdx, :));
        HestHighBlk = lteDLChannelEstimate(rmc, cec, rxGridHigh(:, symIdx, :));  
        
        HestLow = [HestLow HestLowBlk];    %#ok<AGROW>
        HestHigh = [HestHigh HestHighBlk]; %#ok<AGROW>
    end
    
    % ZF equalization
    eqGridLow = lteEqualizeZF(rxGridLow, HestLow);                            
    eqGridHigh = lteEqualizeZF(rxGridHigh, HestHigh);                                    
        
    for i=0:nSubframes-1
        
        if (rmc.PDSCH.CodedTrBlkSizes(rmc.NSubframe+1)~=0)    
            
            % For low edge EVM and high edge EVM:
            for e = 1:2
        
                % Extract the current subframe of equalizer output
                if (e==1)
                    edge = 'Low';
                    eqGrid = eqGridLow(:, i*L+(1:L), :);
                else
                    edge = 'High';
                    eqGrid = eqGridHigh(:, i*L+(1:L), :);
                end
                
                % PDSCH demodulation
                % rxSymbols contains target signal for EVM calculation
                % demodBits are to be used to create reference signal for
                % EVM.
                [ind, info] = ltePDSCHIndices(rmc, rmc.PDSCH, rmc.PDSCH.PRBSet);
                rxSymbols = eqGrid(ind);
                demodBits = ltePDSCHDecode(rmc, rmc.PDSCH, rxSymbols);

                % Decode, recode and remodulate demodBits to give
                % remodSymbols, a vector of reference symbols for EVM
                % calculation.
                [decodedBits, crc] = lteDLSCHDecode(rmc, rmc.PDSCH, ...
                    rmc.PDSCH.TrBlkSizes(rmc.NSubframe+1), demodBits);
                if (sum(crc)~=0)
                    fprintf('CRC failed on decoded data. Subframe %d not taken for EVM.\n',rmc.NSubframe);
                end

                recodedBits = lteDLSCH(rmc, rmc.PDSCH, info.G, decodedBits);
                remodSymbols = ltePDSCH(rmc, rmc.PDSCH, recodedBits);
                
                % Compute and display EVM for this subframe.
                evm(e, i+1) = lteEVM(rxSymbols, remodSymbols); %#ok
                fprintf('%s edge EVM, subframe %d: %0.3f%%\n', ...
                    edge, rmc.NSubframe, evm(e, i+1).RMS*100);
                
            end
            
        end

        % After we've filled a frame, do EVM averaging
        if (mod(i, 10)==9)
           nFrame = floor((i+1)/10);
           frameLowEVM = lteEVM(cat(1, evm(1, i-7:i).EV));
           frameHighEVM = lteEVM(cat(1, evm(2, i-7:i).EV));
           fprintf('\nAveraged low edge EVM, frame %d: %0.3f%%\n', ...
               nFrame-1, frameLowEVM.RMS*100);
           fprintf('Averaged high edge EVM, frame %d: %0.3f%%\n', ...
               nFrame-1, frameHighEVM.RMS*100);           
           if (frameLowEVM.RMS > frameHighEVM.RMS)
               frameEVM(nFrame) = frameLowEVM;
           else
               frameEVM(nFrame) = frameHighEVM;
           end
            fprintf('Averaged EVM frame %d: %0.3f%%\n\n', ...
                nFrame-1, frameEVM(nFrame).RMS*100);           
        end

        % Update subframe number
        rmc.NSubframe = mod(rmc.NSubframe+1, 10);            
        
    end
    
    % Display final averaged EVM across all frames
    finalEVM = lteEVM(cat(1, frameEVM(1:nFrames).EV));
    fprintf('Averaged overall EVM: %0.3f%%\n', finalEVM.RMS*100); 
    
end

function W = getEVMWindow(RMC)
    
    % Numbers of downlink resource blocks
    nrbs = [6 15 25 50 75 100];
    
    % EVM window lengths W for normal CP
    Ws = [5 12 32 66 136 136];
    
    % EVM window lengths W for extended CP  
    if (isfield(RMC,'CyclicPrefix'))
        if(strcmpi(RMC.CyclicPrefix,'Extended'))
            Ws = [28 58 124 250 504 504];
        end
    end

    % Get corresponding EVM window length for NDLRB
    W = Ws(RMC.NDLRB==nrbs);

end