rxWaveform = reshape(Rx,[length(Rx),1]);

% Check for LST presence
if isempty(ver('lte'))
    error('sdrzLTEReceiver:NoLST','Please install LTE System Toolbox to run this example.');
end

% User defined parameters
rxsim.RadioFrontEndSampleRate = 1.92e6; % Configured for 1.92 MHz capture bandwidth

% Derived parameters
samplesPerFrame = 10e-3*rxsim.RadioFrontEndSampleRate; % LTE frames period is 10 ms

%%
% *Spectrum viewer setup*
hsa = dsp.SpectrumAnalyzer( ...
    'SampleRate',      rxsim.RadioFrontEndSampleRate, ...
    'SpectrumType',    'Power density', ...
    'SpectralAverages', 10, ...
    'YLimits',         [-40 40], ...
    'Title',           'Baseband LTE Signal Spectrum', ...
    'YLabel',          'Power spectral density');

% Show power spectral density of captured burst
step(hsa,rxWaveform);

%%
% *LTE Setup*
%
% The parameters for decoding the MIB are contained in the structure |enb|.
% FDD duxplexing mode and a normal cyclic prefix length are assumed. Four
% cell-specific reference ports (CellRefP) are assumed for the MIB decode.
% The number of actual CellRefP is provided by the MIB.

enb.DuplexMode = 'FDD';
enb.CyclicPrefix = 'Normal';
enb.CellRefP = 4;

%%
% The sampling rate of the signal controls the captured bandwidth. The
% number of number of RBs captured is obtained from a lookup table using
% the chosen sampling rate.

% Bandwidth: {1.4 MHz, 3 MHz, 5 MHz, 10 MHz}
SampleRateLUT = [1.92e6 3.84e6 7.68e6 15.36e6];
NDLRBLUT = [6 15 25 50];
enb.NDLRB = NDLRBLUT(SampleRateLUT==rxsim.RadioFrontEndSampleRate);
if isempty(enb.NDLRB)
    error('Sampling rate not supported. Supported rates are 1.92 MHz, 3.84 MHz, 7.68 MHz, 15.36 MHz.');
end
fprintf('SDR hardware sampling rate configured to capture %d LTE RBs.\n',enb.NDLRB);

%%
% Channel estimation configuration using cell-specific reference signals. A
% conservative 9-by-9 averaging window is used to minimize the effect of
% noise.

cec.FreqWindow = 9;               % Frequency averaging window in Resource Elements (REs)
cec.TimeWindow = 9;               % Time averaging window in REs
cec.InterpType = 'Cubic';         % Cubic interpolation
cec.PilotAverage = 'UserDefined'; % Pilot averaging method
cec.InterpWindow = 'Centred';     % Interpolation windowing method
cec.InterpWinSize = 3;            % Interpolate up to 3 subframes simultaneously

%%
% *Signal Processing*
%
% For each
% captured frame the MIB is decoded and if successful the CFI and the PDCCH
% for each subframe are decoded and channel estimate and equalized PDCCH
% symbols are shown.

% Setup the constellation diagram viewer for equalized PDCCH symbols
hcd = comm.ConstellationDiagram('Title','Equalized PDCCH Symbols') ;

% Handle for channel estimate plots
hhest = figure('Visible','Off');

enbDefault = enb;

% Set default LTE parameters
enb = enbDefault;

% Perform frequency offset correction
frequencyOffset = lteFrequencyOffset(enb,rxWaveform);
rxWaveform = lteFrequencyCorrect(enb,rxWaveform,frequencyOffset);
fprintf('Corrected a frequency offset of %g Hz.\n',frequencyOffset)

% Perform the blind cell search to obtain cell identity
[NCellID,frameOffset] = lteCellSearch(enb,rxWaveform);
fprintf('Detected a cell identity of %i.\n',NCellID)
enb.NCellID = NCellID;

% Sync the captured samples to the start of an LTE frame, and trim off
% any samples that are part of an incomplete frame.
rxWaveform = rxWaveform(frameOffset+1:end);
tailSamples = mod(length(rxWaveform),samplesPerFrame);
rxWaveform = rxWaveform(1:end-tailSamples);
enb.NSubframe = 0;

% OFDM demodulation
rxGrid = lteOFDMDemodulate(enb,rxWaveform);

% Perform channel estimation for 4 CellRefP as currently we do not
% know the CellRefP for the eNodeB.
[hest,nest] = lteDLChannelEstimate(enb,cec,rxGrid);

sfDims = lteResourceGridSize(enb);
Lsf = sfDims(2); % OFDM symbols per subframe
LFrame = 10*Lsf; % OFDM symbols per frame
numFullFrames = length(rxWaveform)/samplesPerFrame;

% For each frame decode the MIB and CFI
for frame = 0:(numFullFrames-1)
    fprintf('\nPerforming MIB Decode for frame %i of %i in burst...\n', ...
        frame+1,numFullFrames)
    
    % Extract subframe #0 from each frame of the received resource grid
    % and channel estimate.
    enb.NSubframe = 0;
    rxsf = rxGrid(:,frame*LFrame+(1:Lsf));
    hestsf = hest(:,frame*LFrame+(1:Lsf),:,:);
    
    % PBCH demodulation. Extract resource elements (REs)
    % corresponding to the PBCH from the received grid and channel
    % estimate grid for demodulation. Assume 4 cell-specific reference
    % signals for PBCH decode as initially we do not know actual value.
    enb.CellRefP = 4;
    pbchIndices = ltePBCHIndices(enb);
    [pbchRx,pbchHest] = lteExtractResources(pbchIndices,rxsf,hestsf);
    [~,~,nfmod4,mib,CellRefP] = ltePBCHDecode(enb,pbchRx,pbchHest,nest);
    
    % If PBCH decoding successful CellRefP~=0 then update info
    if ~CellRefP
        fprintf('  No PBCH detected for frame.\n');
        continue;
    end
    
    % With successful PBCH decoding, decode the MIB and obtain system
    % information including system bandwidth
    enb = lteMIB(mib,enb);
    enb.CellRefP = CellRefP; % From ltePBCHDecode
    % Incorporate the nfmod4 value output from the function
    % ltePBCHDecode, as the NFrame value established from the MIB
    % is the system frame number modulo 4.
    enb.NFrame = enb.NFrame+nfmod4;
    fprintf('  Successful MIB Decode.\n')
    fprintf('  Frame number: %d.\n',enb.NFrame);
    
    % The eNodeB transmission bandwidth may be greater than the
    % captured bandwidth, so limit the bandwidth for processing
    enb.NDLRB = min(enbDefault.NDLRB,enb.NDLRB);
    
    % Process subframes within frame
    for sf = 0:9
        % Extract subframe
        enb.NSubframe = sf;
        rxsf = rxGrid(:,frame*LFrame+sf*Lsf+(1:Lsf));
        
        % Perform channel estimation with the correct number of CellRefP
        [hestsf,nestsf] = lteDLChannelEstimate(enb,cec,rxsf);
        
        % PCFICH demodulation. Extract REs corresponding to the PCFICH
        % from the received grid and channel estimate for demodulation.
        pcfichIndices = ltePCFICHIndices(enb);
        [pcfichRx,pcfichHest] = lteExtractResources(pcfichIndices,rxsf,hestsf);
        [cfiBits,recsym] = ltePCFICHDecode(enb,pcfichRx,pcfichHest,nestsf);
        
        % CFI decoding
        enb.CFI = lteCFIDecode(cfiBits);
        fprintf('    Subframe %d, decoded CFI value: %d.\n',sf,enb.CFI);
        
        % PDCCH demodulation. Extract REs corresponding to the PDCCH
        % from the received grid and channel estimate for demodulation.
        pdcchIndices = ltePDCCHIndices(enb);
        [pdcchRx,pdcchHest] = lteExtractResources(pdcchIndices,rxsf,hestsf);
        [pdcchBits,pdcchEq] = ltePDCCHDecode(enb,pdcchRx,pdcchHest,nestsf);
        release(hcd);
        step(hcd,pdcchEq);
    end
    
    % Plot channel estimate between CellRefP 0 and the receive antenna
    focalFrameIdx = frame*LFrame+(1:LFrame);
    set(0,'CurrentFigure',hhest);
    hhest.Visible = 'On';
    surf(abs(hest(:,focalFrameIdx,1,1)));
    xlabel('OFDM symbol index');
    ylabel('Subcarrier index');
    zlabel('Magnitude');
    title('Estimate of Channel Magnitude Frequency Repsonse');
end

%%
% EVM Calculation
rmc = lteRMCDL('R.4');
rmc.NCellID = 17;
rmc.NFrame = 700;
rmc.TotSubframes = 8*10; % 10 subframes per frame
rmc.OCNG = 'On'; % Add noise to unallocated PDSCH resource elements

% Generate RMC waveform
trData = [1;0;0;1]; % Transport data
[eNodeBOutput,txGrid,rmc] = lteRMCDLTool(rmc,trData);
evmmeas = PDSCHEVM(rmc,cec,rxWaveform);