function [plots]=LTEReceiver(Rx,samplingrate,configuration)

rxWaveform = reshape(Rx,[length(Rx),1]);

% Check for LST presence
if isempty(ver('lte'))
    error('sdrzLTEReceiver:NoLST','Please install LTE System Toolbox to run this example.');
end

% User defined parameters
rxsim.RadioFrontEndSampleRate = samplingrate; % Configured for 1.92 MHz capture bandwidth

% Derived parameters
samplesPerFrame = 10e-3*rxsim.RadioFrontEndSampleRate; % LTE frames period is 10 ms

%%
% *Spectrum viewer setup*
persistent hsa
if isempty(hsa)
    hsa = dsp.SpectrumAnalyzer( ...
        'SampleRate',      rxsim.RadioFrontEndSampleRate, ...
        'SpectrumType',    'Power density', ...
        'SpectralAverages', 10, ...
        'YLimits',         [-50 40], ...
        'Title',           'Baseband LTE Signal Spectrum', ...
        'YLabel',          'Power spectral density', ...
        'Position',        [140 67 800 450]);
end

% Show power spectral density of captured burst
step(hsa,rxWaveform);
release(hsa);

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

% Sync the captured samples to the start of an LTE frame, and trim off
% any samples that are part of an incomplete frame.
rxWaveform = rxWaveform(frameOffset+1:end);
tailSamples = mod(length(rxWaveform),samplesPerFrame);
rxWaveform = rxWaveform(1:end-tailSamples);


%%
% EVM Calculation
rmc = lteRMCDL(configuration);
rmc.NCellID = 17;
rmc.NFrame = 700;
rmc.TotSubframes = 8*10; % 10 subframes per frame
rmc.OCNG = 'On'; % Add noise to unallocated PDSCH resource elements

% Generate RMC waveform
trData = [1;0;0;1]; % Transport data
[~,~,rmc] = lteRMCDLTool(rmc,trData);
[~,plots]=PDSCHEVM(rmc,cec,rxWaveform);
end