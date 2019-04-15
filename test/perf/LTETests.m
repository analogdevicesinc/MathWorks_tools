classdef LTETests < matlab.unittest.TestCase
    
    properties
        DevName = 'Pluto';
        CenterFrequency = 2.45e9;
    end
    
    methods(TestMethodSetup)
    end
    
    methods(TestMethodTeardown)
    end
    
    methods (Static)
        
        function evmResults = ReceiverGeneric(config, rxWaveform, ~)
            
            evmResults = LTEReceiver(rxWaveform,...
                config.txsim.SamplingRate,config.rmc);
            
        end
        
        function evmResults = ReceiverR4(config, rxWaveform, txWaveform)
            
            constellation = comm.ConstellationDiagram('Title','Equalized PDCCH Symbols') ;
            
            % Extract config
            rmc = config.rmc;
            
            % Derived parameters
            %             samplesPerFrame = 10e-3*rxsim.RadioFrontEndSampleRate; % LTE frames period is 10 ms
            samplesPerFrame = length(txWaveform); % LTE frames period is 10 ms
            %             samplesPerFrame = length(rxWaveform);
            
            enb.PDSCH = rmc.PDSCH;
            enb.DuplexMode = 'FDD';
            enb.CyclicPrefix = 'Normal';
            enb.CellRefP = 4;
            
            % Bandwidth: {1.4 MHz, 3 MHz, 5 MHz, 10 MHz, 20 MHz}
            SampleRateLUT = [1.92 3.84 7.68 15.36 30.72]*1e6;
            NDLRBLUT = [6 15 25 50 100];
            enb.NDLRB = NDLRBLUT(SampleRateLUT==rmc.SamplingRate);
            if isempty(enb.NDLRB)
                error('Sampling rate not supported. Supported rates are %s.',...
                    '1.92 MHz, 3.84 MHz, 7.68 MHz, 15.36 MHz, 30.72 MHz');
            end
            fprintf('\nSDR hardware sampling rate configured to capture %d LTE RBs.\n',enb.NDLRB);
            % Channel estimation configuration structure
            cec.PilotAverage = 'UserDefined';  % Type of pilot symbol averaging
            cec.FreqWindow = 9;                % Frequency window size in REs
            cec.TimeWindow = 9;                % Time window size in REs
            cec.InterpType = 'Cubic';          % 2D interpolation type
            cec.InterpWindow = 'Centered';     % Interpolation window type
            cec.InterpWinSize = 3;             % Interpolation window size
            
            enbDefault = enb;
            
            % Set default LTE parameters
            enb = enbDefault;
            
            % Perform frequency offset correction for known cell ID
            frequencyOffset = lteFrequencyOffset(enb,rxWaveform);
            rxWaveform = lteFrequencyCorrect(enb,rxWaveform,frequencyOffset);
            fprintf('\nCorrected a frequency offset of %i Hz.\n',frequencyOffset)
            
            % Perform the blind cell search to obtain cell identity and timing offset
            %   Use 'PostFFT' SSS detection method to improve speed
            cellSearch.SSSDetection = 'PostFFT'; cellSearch.MaxCellCount = 1;
            [NCellID,frameOffset] = lteCellSearch(enb,rxWaveform,cellSearch);
            fprintf('Detected a cell identity of %i.\n', NCellID);
            enb.NCellID = NCellID; % From lteCellSearch
            
            % Sync the captured samples to the start of an LTE frame, and trim off
            % any samples that are part of an incomplete frame.
            rxWaveform = rxWaveform(frameOffset+1:end,:);
            tailSamples = mod(length(rxWaveform),samplesPerFrame);
            rxWaveform = rxWaveform(1:end-tailSamples,:);
            enb.NSubframe = 0;
            fprintf('Corrected a timing offset of %i samples.\n',frameOffset)
            
            % OFDM demodulation
            rxGrid = lteOFDMDemodulate(enb,rxWaveform);
            
            % Perform channel estimation for 4 CellRefP as currently we do not
            % know the CellRefP for the eNodeB.
            [hest,nest] = lteDLChannelEstimate(enb,cec,rxGrid);
            
            sfDims = lteResourceGridSize(enb);
            Lsf = sfDims(2); % OFDM symbols per subframe
            LFrame = 10*Lsf; % OFDM symbols per frame
            numFullFrames = length(rxWaveform)/samplesPerFrame;
            %             numFullFrames = 10;
            
            rxDataFrame = zeros(sum(enb.PDSCH.TrBlkSizes(:)),numFullFrames);
            recFrames = zeros(numFullFrames,1);
            rxSymbols = []; txSymbols = [];
            evmRMS = []; evmPeak = [];
            
            evmResults = zeros(1,2);
            
            % For each frame decode the MIB, PDSCH and DL-SCH
            for frame = 0:(numFullFrames-1)
                fprintf('\nPerforming DL-SCH Decode for frame %i of %i in burst:\n', ...
                    frame+1,numFullFrames)
                
                % Extract subframe #0 from each frame of the received resource grid
                % and channel estimate.
                enb.NSubframe = 0;
                rxsf = rxGrid(:,frame*LFrame+(1:Lsf),:);
                hestsf = hest(:,frame*LFrame+(1:Lsf),:,:);
                
                % PBCH demodulation. Extract resource elements (REs)
                % corresponding to the PBCH from the received grid and channel
                % estimate grid for demodulation.
                enb.CellRefP = 4;
                pbchIndices = ltePBCHIndices(enb);
                [pbchRx,pbchHest] = lteExtractResources(pbchIndices,rxsf,hestsf);
                [~,~,nfmod4,mib,CellRefP] = ltePBCHDecode(enb,pbchRx,pbchHest,nest);
                
                % If PBCH decoding successful CellRefP~=0 then update info
                if ~CellRefP
                    fprintf('  No PBCH detected for frame.\n');
                    continue;
                end
                enb.CellRefP = CellRefP; % From ltePBCHDecode
                
                % Decode the MIB to get current frame number
                enb = lteMIB(mib,enb);
                
                % Incorporate the nfmod4 value output from the function
                % ltePBCHDecode, as the NFrame value established from the MIB
                % is the system frame number modulo 4.
                enb.NFrame = enb.NFrame+nfmod4;
                fprintf('  Successful MIB Decode.\n')
                fprintf('  Frame number: %d.\n',enb.NFrame);
                
                % The eNodeB transmission bandwidth may be greater than the
                % captured bandwidth, so limit the bandwidth for processing
                enb.NDLRB = min(enbDefault.NDLRB,enb.NDLRB);
                
                % Store received frame number
                recFrames(frame+1) = enb.NFrame;
                
                % Process subframes within frame (ignoring subframe 5)
                for sf = 0:9
                    if sf~=5 % Ignore subframe 5
                        % Extract subframe
                        enb.NSubframe = sf;
                        rxsf = rxGrid(:,frame*LFrame+sf*Lsf+(1:Lsf),:);
                        
                        % Perform channel estimation with the correct number of CellRefP
                        [hestsf,nestsf] = lteDLChannelEstimate(enb,cec,rxsf);
                        
                        % PCFICH demodulation. Extract REs corresponding to the PCFICH
                        % from the received grid and channel estimate for demodulation.
                        pcfichIndices = ltePCFICHIndices(enb);
                        [pcfichRx,pcfichHest] = lteExtractResources(pcfichIndices,rxsf,hestsf);
                        [cfiBits,~] = ltePCFICHDecode(enb,pcfichRx,pcfichHest,nestsf);
                        
                        % CFI decoding
                        enb.CFI = lteCFIDecode(cfiBits);
                        
                        % Get PDSCH indices
                        [pdschIndices,pdschIndicesInfo] = ltePDSCHIndices(enb, enb.PDSCH, enb.PDSCH.PRBSet);
                        [pdschRx, pdschHest] = lteExtractResources(pdschIndices, rxsf, hestsf);
                        
                        % Perform deprecoding, layer demapping, demodulation and
                        % descrambling on the received data using the estimate of
                        % the channel
                        [rxEncodedBits, rxEncodedSymb] = ltePDSCHDecode(enb,enb.PDSCH,pdschRx,...
                            pdschHest,nestsf);
                        
                        pdcchIndices = ltePDCCHIndices(enb);
                        [pdcchRx,pdcchHest] = lteExtractResources(pdcchIndices,rxsf,hestsf);
                        [~,pdcchEq] = ltePDCCHDecode(enb,pdcchRx,pdcchHest,nestsf);
                        release(constellation);
                        constellation(pdcchEq);
                        pause(0);
                        
                        % Append decoded symbol to stream
                        rxSymbols = [rxSymbols; rxEncodedSymb{:}]; %#ok<AGROW>
                        
                        % Transport block sizes
                        outLen = enb.PDSCH.TrBlkSizes(enb.NSubframe+1);
                        
                        % Decode DownLink Shared Channel (DL-SCH)
                        [decbits{sf+1}, blkcrc(sf+1)] = lteDLSCHDecode(enb,enb.PDSCH,...
                            outLen, rxEncodedBits);  %#ok<NASGU,AGROW>
                        
                        % Recode transmitted PDSCH symbols for EVM calculation
                        %   Encode transmitted DLSCH
                        txRecode = lteDLSCH(enb,enb.PDSCH,pdschIndicesInfo.G,decbits{sf+1});
                        %   Modulate transmitted PDSCH
                        txRemod = ltePDSCH(enb, enb.PDSCH, txRecode);
                        %   Decode transmitted PDSCH
                        [~,refSymbols] = ltePDSCHDecode(enb, enb.PDSCH, txRemod);
                        %   Add encoded symbol to stream
                        txSymbols = [txSymbols; refSymbols{:}]; %#ok<AGROW>
                        
                        evmCalculator = comm.EVM();
                        evmCalculator.MaximumEVMOutputPort = true;
                        [evm.RMS,evm.Peak] = evmCalculator(refSymbols{:}, rxEncodedSymb{:});
                        fprintf('  EVM peak = %0.3f%%\n',evm.Peak);
                        fprintf('  EVM RMS  = %0.3f%%\n',evm.RMS);
                        evmRMS = [evmRMS; evm.RMS]; %#ok<AGROW>
                        evmPeak = [evmPeak; evm.Peak]; %#ok<AGROW>
                        
                    end
                end
                
                % Reassemble decoded bits
                fprintf('  Retrieving decoded transport block data.\n');
                rxdata = [];
                for i = 1:length(decbits)
                    if i~=6 % Ignore subframe 5
                        rxdata = [rxdata; decbits{i}{:}]; %#ok<AGROW>
                    end
                end
                
                % Store data from receive frame
                rxDataFrame(:,frame+1) = rxdata;
            end
            
            %%
            % *Result Qualification and Display*
            %
            % The bit error rate (BER) between the transmitted and received data is
            % calculated to determine the quality of the received data. The received
            % data is then reformed into an image and displayed.
            
            % Determine index of first transmitted frame (lowest received frame number)
            [~,frameIdx] = min(recFrames);
            
            fprintf('\nRecombining received data blocks:\n');
            
            decodedRxDataStream = zeros(length(rxDataFrame(:)),1);
            frameLen = size(rxDataFrame,1);
            % Recombine received data blocks (in correct order) into continuous stream
            for n=1:numFullFrames
                currFrame = mod(frameIdx-1,numFullFrames)+1; % Get current frame index
                decodedRxDataStream((n-1)*frameLen+1:n*frameLen) = rxDataFrame(:,currFrame);
                frameIdx = frameIdx+1; % Increment frame index
            end
            
            % Perform EVM calculation
            if ~isempty(rxSymbols)
%                 evmCalculator = comm.EVM();
%                 evmCalculator.MaximumEVMOutputPort = true;
%                 [evm.RMS,evm.Peak] = evmCalculator(txSymbols, rxSymbols);
%                 fprintf('  EVM peak = %0.3f%%\n',evm.Peak);
%                 fprintf('  EVM RMS  = %0.3f%%\n',evm.RMS);
%                 evmResults(1) = evm.RMS;
%                 evmResults(2) = evm.Peak;
                % Remove outliers
                m = mean(evmPeak);
                i = find(evmPeak>m*3);
                evmRMS(i) = [];
                evmPeak(i) = [];
                evmResults(1) = mean(evmRMS);
                evmResults(2) = mean(evmPeak);
                fprintf('  EVM peak = %0.3f%%\n',evmResults(2));
                fprintf('  EVM RMS  = %0.3f%%\n',evmResults(1));
                
            else
                fprintf('  No transport blocks decoded.\n');
            end
            

        end
        
        function [eNodeBOutput,config] = TransmitterGeneric(LTEmode)
            
            
            if strcmp(LTEmode,'LTE1.4') == 1
                configuration = 'R.4';
%                 samplingrate = 1.92e6;
%                 bandwidth = 1.08e6;
%                 fir_data_file = 'LTE1p4_MHz.ftr';
            elseif strcmp(LTEmode,'LTE3') == 1
                configuration = 'R.5';
%                 samplingrate = 3.84e6;
%                 bandwidth = 2.7e6;
%                 fir_data_file = 'LTE3_MHz.ftr';
            elseif strcmp(LTEmode,'LTE5') == 1
                configuration = 'R.6';
%                 samplingrate = 7.68e6;
%                 bandwidth = 4.5e6;
%                 fir_data_file = 'LTE5_MHz.ftr';
            elseif strcmp(LTEmode,'LTE10') == 1
                configuration = 'R.7';
%                 samplingrate = 15.36e6;
%                 bandwidth = 9e6;
%                 fir_data_file = 'LTE10_MHz.ftr';
            else
                error('Please input LTE1.4, LTE3, LTE5 or LTE10.');
            end

            % Generate the LTE signal
            txsim.RC = configuration; % Base RMC configuration
            txsim.NCellID = 17;       % Cell identity
            txsim.NFrame = 700;       % Initial frame number
            txsim.TotFrames = 1;      % Number of frames to generate
            txsim.RunTime = 20;       % Time period to loop waveform in seconds
%             txsim.DesiredCenterFrequency = 2.45e9; % Center frequency in Hz
            txsim.NTxAnts = 1;
            
            % Generate RMC configuration and customize parameters
            rmc = lteRMCDL(txsim.RC);
            rmc.NCellID = txsim.NCellID;
            rmc.NFrame = txsim.NFrame;
%             rmc.TotSubframes = txsim.TotFrames*10; % 10 subframes per frame
            rmc.TotSubframes = txsim.TotFrames*10; % 10 subframes per frame
            % Add noise to unallocated PDSCH resource elements
            if verLessThan('matlab','9.2')
                rmc.OCNG = 'On';
            else
                rmc.OCNGPDSCHEnable = 'On';
                rmc.OCNGPDCCHEnable = 'On';
            end
            
            % Generate RMC waveform
            trData = [1;0;0;1]; % Transport data
            [eNodeBOutput,~,rmc] = lteRMCDLTool(rmc,trData);
            txsim.SamplingRate = rmc.SamplingRate;
            
            % Scale the signal for better power output and cast to int16. This is the
            % native format for the SDR hardware. Since we are transmitting the same
            % signal in a loop, we can do the cast once to save processing time.
            powerScaleFactor = 0.7;
            eNodeBOutput = eNodeBOutput.*(1/max(abs(eNodeBOutput))*powerScaleFactor);
            eNodeBOutput = int16(eNodeBOutput*2^15);
            
            % User defined parameters --- configure the same as transmitter
            rxsim = struct;
            rxsim.NRxAnts = txsim.NTxAnts;
            rxsim.FramesPerBurst = txsim.TotFrames+1; % Number of LTE frames to capture in each burst.
            rxsim.numBurstCaptures = 1; % Number of bursts to capture
            
            % Pack configuration
            config = struct;
            config.txsim = txsim;
            config.rxsim = rxsim;
            config.rmc = rmc;
            
        end
        
        function [eNodeBOutput, config] = TransmitterR4()
            %% Generate some data
            % Input an image file and convert to binary stream
            fileTx = 'peppers.png';            % Image file name
            fData = imread(fileTx);            % Read image data from file
            scale = 0.5;                       % Image scaling factor
            origSize = size(fData);            % Original input image size
            scaledSize = max(floor(scale.*origSize(1:2)),1); % Calculate new image size
            heightIx = min(round(((1:scaledSize(1))-0.5)./scale+0.5),origSize(1));
            widthIx = min(round(((1:scaledSize(2))-0.5)./scale+0.5),origSize(2));
            fData = fData(heightIx,widthIx,:); % Resize image
%             imsize = size(fData);              % Store new image size
            binData = dec2bin(fData(:),8);     % Convert to 8 bit unsigned binary
            trData = reshape((binData-'0').',1,[]).'; % Create binary stream
            trData = trData(1:2^20);
            
            %% Build configuration
            %  Initialize SDR device
            txsim = struct; % Create empty structure for transmitter
            txsim.RC = 'R.4';       % Base RMC configuration, 10 MHz bandwidth
            txsim.NCellID = 88;     % Cell identity
            txsim.NFrame = 700;     % Initial frame number
            txsim.TotFrames = 1;    % Number of frames to generate
            txsim.NTxAnts = 1;
            txsim.Gain = -10;
            txsim.trData = trData;
            
            % Create RMC
            rmc = lteRMCDL(txsim.RC);
            % Customize RMC parameters
            rmc.NCellID = txsim.NCellID;
            rmc.NFrame = txsim.NFrame;
            rmc.TotSubframes = txsim.TotFrames*10; % 10 subframes per frame
            rmc.CellRefP = txsim.NTxAnts; % Configure number of cell reference ports
            rmc.PDSCH.RVSeq = 0;
            % Fill subframe 5 with dummy data
            rmc.OCNGPDSCHEnable = 'On';
            rmc.OCNGPDCCHEnable = 'On';
            
            % If transmitting over two channels enable transmit diversity
            if rmc.CellRefP == 2
                rmc.PDSCH.TxScheme = 'TxDiversity';
                rmc.PDSCH.NLayers = 2;
                rmc.OCNGPDSCH.TxScheme = 'TxDiversity';
            end
            
            trBlkSize = rmc.PDSCH.TrBlkSizes;
            txsim.TotFrames = ceil(numel(trData)/sum(trBlkSize(:)));
            
            % Pack the image data into a single LTE frame
            [eNodeBOutput,~,rmc] = lteRMCDLTool(rmc,trData);
            
            % Scale the signal for better power output.
            powerScaleFactor = 0.8;
            if txsim.NTxAnts == 2
                eNodeBOutput = [eNodeBOutput(:,1).*(1/max(abs(eNodeBOutput(:,1)))*powerScaleFactor) ...
                    eNodeBOutput(:,2).*(1/max(abs(eNodeBOutput(:,2)))*powerScaleFactor)];
            else
                eNodeBOutput = eNodeBOutput.*(1/max(abs(eNodeBOutput))*powerScaleFactor);
            end
            
            % Cast the transmit signal to int16 ---
            % this is the native format for the SDR hardware.
            eNodeBOutput = int16(eNodeBOutput*2^15);
            
            % User defined parameters --- configure the same as transmitter
            rxsim = struct;
            rxsim.NRxAnts = txsim.NTxAnts;
            rxsim.FramesPerBurst = txsim.TotFrames+1; % Number of LTE frames to capture in each burst.
            rxsim.numBurstCaptures = 1; % Number of bursts to capture
            
            % Pack configuration
            config = struct;
            config.txsim = txsim;
            config.rxsim = rxsim;
            config.rmc = rmc;
            
        end
        
    end
    
    methods
        function [data,config] = TransmitterLTE(testCase, name)
            switch name
                case 'R4'
                    [data, config] = testCase.TransmitterR4();
                otherwise
                    [data, config] = testCase.TransmitterGeneric(name);
%                     error('Unknown configuration');
            end
        end
        
        function results = ReceiverLTE(testCase, name, config, rxWaveform, txWaveform)
            switch name
                case 'R4'
                    results = testCase.ReceiverR4(config, rxWaveform, txWaveform);
                otherwise
                    results = testCase.ReceiverGeneric(config, rxWaveform, txWaveform);
%                     error('Unknown configuration');
            end
        end
    end
    
end