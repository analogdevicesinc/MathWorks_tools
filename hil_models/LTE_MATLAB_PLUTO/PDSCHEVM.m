function [finalEVM,plots] = PDSCHEVM(enb,cec,rxWaveform)

% Control over receiver corrections to be performed:
persistent hcd
if isempty(hcd)
    hcd = comm.ConstellationDiagram('Title','Received Data Symbols');
    hcd.Position = [140 540 460 383];
    hcd.ShowReferenceConstellation = false;
end
% Frequency offset correction with estimation in the time domain based
% on cyclic prefix correlation; estimation/correction applies to each
% subframe.
correctFreqOffsetCPCorr = true;

% IQ offset correction with estimation of the mean of the signal in the
% time domain; estimation/correction applies to each subframe.
correctIQOffset = true;

% Frequency offset correction with estimation in the frequency domain
% based on the phase shift between channel estimate REs in the
% locations of successive Cell-Specific Reference Signal (Cell RS)
% symbols; estimation/correction applies to each subframe. This
% estimator is more accurate for small frequency offsets than
% estimation in the time domain.
correctFreqOffsetCellRS = true;

% Compute some parameters.
dims = lteOFDMInfo(enb);
samplesPerSubframe = dims.SamplingRate/1000;
nSubframes = floor(size(rxWaveform, 1)/samplesPerSubframe);
nFrames = floor(nSubframes/10);
W = getEVMWindow(enb);
if (mod(W,2)==0)
    alpha = 0;
else
    alpha = 1;
end

cpLength=double(dims.CyclicPrefixLengths(2));

gridDims = lteResourceGridSize(enb);
L = gridDims(2);

% Pad on the tail to allow for CP correlation.
rxWaveform = [rxWaveform; zeros(dims.Nfft, size(rxWaveform, 2))];

if (isfield(enb,'TMN'))
    % Create reference test model grid
    [~,refGrid] = lteTestModelTool(setfield(enb,'TotSubframes',nSubframes));
end

% Setup plots
[evmGridFigure,evmSymbolPlot,evmSubcarrierPlot,evmRBPlot] = hEVMPlots();
evmSubcarrierPlot.ShowLegend = false;
evmSubcarrierPlot.Title = 'Yellow: RMS   Blue: Peak';
evmSymbolPlot.ShowLegend = false;
evmSymbolPlot.Title = 'Yellow: RMS   Blue: Peak';
evmRBPlot.ShowLegend = false;
evmRBPlot.Title = 'Yellow: RMS   Blue: Peak';
if (nSubframes>0)
    evmSymbolPlot.TimeSpan = (L*nSubframes)-1;
end

% For each subframe:
rxGridLow = [];
rxGridHigh = [];
frameEVM = repmat(lteEVM([]), 1, max(nFrames,1));
delta_f_tilde_old = 0.0;
p = 1;
evm = repmat(lteEVM([]), 2, nSubframes);
for i = 0:nSubframes-1
    
    % Extract this subframe.
    rxSubframe = rxWaveform( ...
        i*samplesPerSubframe+(1:(samplesPerSubframe+dims.Nfft)), :);
    
    % Do frequency offset estimation and correction for this subframe
    if (correctFreqOffsetCPCorr)
        delta_f_tilde = lteFrequencyOffset(enb, rxSubframe, 0);
    else
        delta_f_tilde = 0; %#ok<UNRCH>
    end
    rxSubframeFreqCorrected = lteFrequencyCorrect( ...
        enb, rxSubframe(1:samplesPerSubframe, :), delta_f_tilde);
    
    % Perform IQ offset correction
    if (correctIQOffset)
        iqoffset = mean(rxSubframeFreqCorrected);
        rxSubframeFreqCorrected = ...
            rxSubframeFreqCorrected - ...
            repmat(iqoffset, size(rxSubframeFreqCorrected, 1), 1);
    end
    
    % Additional CRS-based frequency offset estimation and correction
    if (correctFreqOffsetCellRS)
        rxGrid = lteOFDMDemodulate(enb, rxSubframeFreqCorrected);
        delta_f_tilde_crs = frequencyOffsetCellRS( ...
            setfield(enb,'NSubframe',i), cec, rxGrid); %#ok<*SFLD>
        rxSubframeFreqCorrected = lteFrequencyCorrect( ...
            enb, rxSubframeFreqCorrected, delta_f_tilde_crs);
        delta_f_tilde = delta_f_tilde + delta_f_tilde_crs;
    end
    
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
                enb, rxSubframeFreqCorrected, cpFraction)]; %#ok<AGROW>
        else
            cpFraction = (cpLength/2 + floor(W/2))/cpLength;
            rxGridHigh = [rxGridHigh lteOFDMDemodulate( ...
                enb, rxSubframeFreqCorrected, cpFraction)]; %#ok<AGROW>
        end
        
    end
    
end

% Channel estimation.
% Allow channel estimates to be processed in blocks of 10 subframes if
% TestEVM channel estimate is used as per TS36.141 Annex F.3.4
if strcmpi(cec.PilotAverage,'TestEVM')
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
    
    HestLowBlk = lteDLChannelEstimate(enb, cec, rxGridLow(:, symIdx, :));
    HestHighBlk = lteDLChannelEstimate(enb, cec, rxGridHigh(:, symIdx, :));
    
    HestLow = [HestLow HestLowBlk];    %#ok<AGROW>
    HestHigh = [HestHigh HestHighBlk]; %#ok<AGROW>
end

evmGridLow = [];
evmGridHigh = [];
for i=0:nSubframes-1
    
    % ZF equalization
    eqGridLow = lteEqualizeZF(rxGridLow(:, i*L+(1:L), :), HestLow(:, i*L+(1:L), :, :));
    eqGridHigh = lteEqualizeZF(rxGridHigh(:, i*L+(1:L), :), HestHigh(:, i*L+(1:L), :, :));
    
    if (isfield(enb,'TMN') || any(enb.PDSCH.CodedTrBlkSizes(:,enb.NSubframe+1)~=0))
        
        % For low edge EVM and high edge EVM:
        for e = 1:2
            
            % Select the low or high edge equalizer output
            if (e==1)
                edge = 'Low';
                eqGrid = eqGridLow;
            else
                edge = 'High';
                eqGrid = eqGridHigh;
            end
            
            if (isfield(enb,'TMN'))
                % using Test Model configuration
                
                ind = ltePDSCHIndices(enb, enb.PDSCH, (0:enb.NDLRB-1).');
                rxSymbols = eqGrid(ind);
                refSubframe = refGrid(:, i*L+(1:L), :);
                refSymbols = refSubframe(ind);
                
            else
                % using RMC configuration
                
                % PDSCH demodulation
                % rxSymbols contains target signal for EVM calculation
                % demodBits are to be used to create reference signal for
                % EVM.
                [ind, info] = ltePDSCHIndices(enb, enb.PDSCH, enb.PDSCH.PRBSet);
                rxSymbols = eqGrid(ind);
                demodBits = ltePDSCHDecode(enb, enb.PDSCH, rxSymbols);
                
                % Decode, recode and remodulate demodBits to give
                % remodSymbols, a vector of reference symbols for EVM
                % calculation.
                [decodedBits, crc] = lteDLSCHDecode(enb, enb.PDSCH, ...
                    enb.PDSCH.TrBlkSizes(:,enb.NSubframe+1), demodBits);
                if (sum(crc)~=0)
                    fprintf('CRC failed on decoded data. Subframe %d not taken for EVM.\n',enb.NSubframe);
                end
                
                recodedBits = lteDLSCH(enb, enb.PDSCH, info.G, decodedBits);
                refSymbols = ltePDSCH(enb, enb.PDSCH, recodedBits);
                
            end
            
            % Compute and display EVM for this subframe.
            evm(e, i+1) = lteEVM(rxSymbols, refSymbols);
            
            step(hcd,rxSymbols);
            release(hcd);
            fprintf('%s edge EVM, subframe %d: %0.3f%%\n', ...
                edge, enb.NSubframe, evm(e, i+1).RMS*100);
            
        end
        
    else
        ind = ltePDSCHIndices(enb, enb.PDSCH, []);
    end
    
    % update EVM plots
    updateEVMPlots();
    
    % After we've filled a frame or if we're at the end of a signal
    % shorter than a frame, do EVM averaging
    if (mod(i, 10)==9 || (nFrames==0 && i==nSubframes-1))
        if (nFrames==0)
            sfrange = 1:nSubframes;
            nFrame = 1;
        else
            sfrange = i-8:i+1;
            nFrame = floor((i+1)/10);
        end
        frameLowEVM = lteEVM(cat(1, evm(1, i-7:i).EV));
        frameHighEVM = lteEVM(cat(1, evm(2, i-7:i).EV));
        if (nFrames~=0)
            fprintf('Averaged low edge EVM, frame %d: %0.3f%%\n', ...
                nFrame-1, frameLowEVM.RMS*100);
            fprintf('Averaged high edge EVM, frame %d: %0.3f%%\n', ...
                nFrame-1, frameHighEVM.RMS*100);
        end
        if (frameLowEVM.RMS > frameHighEVM.RMS)
            frameEVM(nFrame) = frameLowEVM;
        else
            frameEVM(nFrame) = frameHighEVM;
        end
        if (nFrames~=0)
            fprintf('Averaged EVM frame %d: %0.3f%%\n', ...
                nFrame-1, frameEVM(nFrame).RMS*100);
        end
    end
    
    % Update subframe number
    enb.NSubframe = mod(enb.NSubframe+1, 10);
    
end

% Display final averaged EVM across all frames
finalEVM = lteEVM(cat(1, frameEVM(:).EV));
fprintf('Averaged overall EVM: %0.3f%%\n', finalEVM.RMS*100);

% create array of plots
plots = {evmSymbolPlot,evmSubcarrierPlot,evmRBPlot,evmGridFigure};

    function updateEVMPlots()
        % build low and high edge EVM resource grids across all
        % subframes (for plotting)
        evmSubframeLow = lteDLResourceGrid(enb,1);
        evmSubframeHigh = evmSubframeLow;
        includeUnallocated = true; % include unallocated RBs in plots
        if (~isfield(enb,'TMN') && includeUnallocated)
            if (isempty(ind))
                unallocRB = [];
            else
                unallocRB = setdiff((0:enb.NDLRB-1).',enb.PDSCH.PRBSet);
            end
            unallocInd = ltePDSCHIndices(enb, enb.PDSCH, unallocRB);
            evmSubframeLow(unallocInd(:,1)) = abs(sum(eqGridLow(unallocInd),2))*100;
            evmSubframeHigh(unallocInd(:,1)) = abs(sum(eqGridHigh(unallocInd),2))*100;
        end
        evmSubframeLow(ind(:,1)) = abs(evm(1,i+1).EV)*100;
        evmSubframeHigh(ind(:,1)) = abs(evm(2,i+1).EV)*100;
        evmGridLow = cat(2, evmGridLow, evmSubframeLow);
        evmGridHigh = cat(2, evmGridHigh, evmSubframeHigh);
        % the low or high edge timing is chosen for plotting
        % automatically based on whichever has the largest RMS across
        % all subframes
        evmMaxLow = max([evm(1,:).RMS]);
        evmMaxHigh = max([evm(2,:).RMS]);
        if (evmMaxLow > evmMaxHigh)
            evmGrid = evmGridLow;
            evmSubframe = evmSubframeLow;
        else
            evmGrid = evmGridHigh;
            evmSubframe = evmSubframeHigh;
        end
        % maximum EVM, used for plot limits scaling
        maxEVM = max(evmGrid(:));
        % plot EVM versus OFDM symbol
        evmSymbolRMS = sqrt(sum(evmSubframe.^2,1)./sum(evmSubframe~=0,1)).';
        evmSymbolPeak = (max(evmSubframe,[],1)./any(evmSubframe~=0,1)).';
        step(evmSymbolPlot,[evmSymbolRMS evmSymbolPeak]);
        evmSymbolPlot.YLimits = [0 maxEVM*1.1];
        % plot EVM versus subcarrier
        evmSubcarrierRMS = sqrt(sum(evmGrid.^2,2)./sum(evmGrid~=0,2));
        evmSubcarrierPeak = max(evmGrid,[],2)./any(evmGrid~=0,2);
        step(evmSubcarrierPlot,[evmSubcarrierRMS evmSubcarrierPeak]);
        evmSubcarrierPlot.YLimits = [0 maxEVM*1.1];
        % plot EVM versus resource block
        evmRBRMS = zeros(enb.NDLRB,1);
        evmRBPeak = evmRBRMS;
        for rb = 0:enb.NDLRB-1
            rbGrid = evmGrid(rb*12 + (1:12),:,:);
            evmRBRMS(rb+1) = sqrt(sum(rbGrid(:).^2)./sum(rbGrid(:)~=0));
            evmRBPeak(rb+1) = max(rbGrid(:))./any(rbGrid(:)~=0);
        end
        step(evmRBPlot,[[evmRBRMS; evmRBRMS(end)] [evmRBPeak; evmRBPeak(end)]]);
        evmRBPlot.YLimits = [0 maxEVM*1.1];
        % plot EVM resource grid
        evmGridFigure = hEVMPlots(evmGridFigure, evmGrid);
        evmGridFigure.CurrentAxes.ZLim = [0 maxEVM*1.1];
    end
end



% getEVMWindow EVM window
%   W = getEVMWindow(ENB) is the error vector magnitude window, W, for an
%   eNodeB configuration ENB.
%
%   NOTE: W for bandwidth 15MHz has been scaled because the LTE System
%   Toolbox(TM) uses 2048-point FFT for 15MHz rather than 1536-point.

%   Copyright 2011-2014 The MathWorks, Inc.

function W = getEVMWindow(enb)

% Numbers of downlink resource blocks
nrbs = [6 15 25 50 75 100];

% EVM window lengths W for normal CP
Ws = [5 12 32 66 136 136];

% EVM window lengths W for extended CP
if (isfield(enb,'CyclicPrefix'))
    if(strcmpi(enb.CyclicPrefix,'Extended'))
        Ws = [28 58 124 250 504 504];
    end
end

% Get corresponding EVM window length for NDLRB
W = Ws(enb.NDLRB==nrbs);

end

% Estimates the average frequency offset by means of estimation of the
% phase shift between channel estimate REs in the locations of successive
% Cell-Specific Reference Signal (Cell RS) symbols. The approach used
% follows Equation 14 of Speth, M.; Fechtel, S.; Fock, G.; Meyr, H.,
% "Optimum receiver design for OFDM-based broadband transmission .II. A
% case study," Communications, IEEE Transactions on , vol.49, no.4,
% pp.571,578, Apr 2001.
function foffset = frequencyOffsetCellRS(enb,cec,rxgrid)

% If the 'TestEVM' channel estimator is specified, use 1x1 pilot
% averaging instead. The 'TestEVM' channel estimator gives the same
% channel estimate across all OFDM symbols which makes it unsuitable,
% because the technique here relies on an estimate of the phase shift
% across OFDM symbols.
if (strcmpi(cec.PilotAverage,'TestEVM'))
    cec.PilotAverage = 'UserDefined';
    cec.FreqWindow = 1;
    cec.TimeWindow = 1;
    cec.InterpWinSize = 1;
    cec.InterpWindow = 'Centred';
    cec.InterpType = 'cubic';
end

% perform channel estimation
hest = lteDLChannelEstimate(enb,cec,rxgrid);

% set some housekeeping variables
dims = lteDLResourceGridSize(enb);
K = dims(1);
L = dims(2);
nsf = floor(size(hest,2)/L);
startsf = enb.NSubframe;
xleft = 0;
xright = 0;

% for each receive antenna:
for r = 1:size(hest,3)
    
    % for each transmit antenna up to a maximum of 2 (because the cell
    % RS layout is unsuitable for the 3rd and 4th antennas, there is
    % only one RE across all OFDM symbols):
    for p = 1:min(size(hest,4),2)
        
        % for each subframe:
        for i = 0:nsf-1
            
            xsf = [];
            enb.NSubframe = mod(startsf+i,10);
            
            % extract the current subframe of the channel estimate
            hsubframe = hest(:,(i*L)+(1:L),r,p);
            
            % extract the channel estimate REs in the location of the
            % cell-specific reference signal
            cellrsind = lteCellRSIndices(enb,p-1) - ((p-1)*K*L);
            hcellrs = hsubframe(cellrsind);
            
            % establish the set of frequency indices 'kset' occupied by
            % the cell-specific reference signal
            cellrssub = lteCellRSIndices(enb,p-1,'sub');
            kset = double(unique(cellrssub(:,1)));
            
            % for each frequency index:
            for kidx = 1:length(kset)
                
                % calculate the correlation 'x' between the two
                % occurrences of the cell-specific reference signal in
                % this frequency index and store it in the vector 'xsf'
                % of all correlations for this subframe. The spacing in
                % OFDM symbols 'delta_l' is also calculated.
                k = kset(kidx);
                thisidx = (cellrssub(:,1)==k);
                thisl = cellrssub(thisidx,2);
                delta_l = double(diff(thisl));
                h = hcellrs(thisidx);
                x = h(2)*conj(h(1));
                xsf = [xsf x]; %#ok<AGROW>
                
            end
            
            % accumulate the correlations in each half of the spectrum
            xleft = xleft + sum(xsf(kset<=K/2));
            xright = xright + sum(xsf(kset>K/2));
            
        end
        
    end
    
end

% compute OFDM symbol length 'N' and cyclic prefix length 'Ng'
ofdmInfo = lteOFDMInfo(enb);
N = double(ofdmInfo.Nfft);
Ng = double(ofdmInfo.CyclicPrefixLengths(2));

% compute frequency offset estimate based on the phase shift across the
% number of OFDM symbols give by 'delta_l'. The phase angle of the sum
% of all the correlations in each half of the spectrum is calculated
% and these are added together which removes the effect of any
% sampling clock offset - a sampling clock offset creates a
% frequency-dependent phase shift whose sign is different in the two
% halfs of the spectrum, so adding the halfs cancels this effect.
delta_f_tilde = ...
    1/(2*pi*delta_l*(1+Ng/N))*(1/2)*(angle(xleft)+angle(xright));
foffset = delta_f_tilde*15000;

end