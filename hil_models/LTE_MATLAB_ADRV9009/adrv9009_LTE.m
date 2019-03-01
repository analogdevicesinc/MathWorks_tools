function [plots,rssi1,rssi2]=adrv9009_LTE(ip,LTEmode)

clc;

%% Pick up LTE parameters according to LTE Mode
if strcmp(LTEmode,'LTE1.4') == 1
    configuration = 'R.4';
    samplingrate = 1.92e6;
%     bandwidth = 1.08e6;
%     fir_data_file = 'LTE1p4_MHz.ftr';
elseif strcmp(LTEmode,'LTE3') == 1
    configuration = 'R.5';
    samplingrate = 3.84e6;
%     bandwidth = 2.7e6;
%     fir_data_file = 'LTE3_MHz.ftr';
elseif strcmp(LTEmode,'LTE5') == 1
    configuration = 'R.6';
    samplingrate = 7.68e6;
%     bandwidth = 4.5e6;
%     fir_data_file = 'LTE5_MHz.ftr';
elseif strcmp(LTEmode,'LTE10') == 1
    configuration = 'R.7';
    samplingrate = 15.36e6;
%     bandwidth = 9e6;
%     fir_data_file = 'LTE10_MHz.ftr';
else
    error('Please input LTE1.4, LTE3, LTE5 or LTE10.');
end

%% Generate LTE Signal using LTE System Toolbox

% Check for LST presence
if isempty(ver('lte'))
    error('ad9361_LTE:NoLST','Please install LTE System Toolbox to run this example.');
end

% Generate the LTE signal
txsim.RC = configuration; % Base RMC configuration
txsim.NCellID = 17;       % Cell identity
txsim.NFrame = 700;       % Initial frame number
txsim.TotFrames = 1;      % Number of frames to generate
txsim.RunTime = 20;       % Time period to loop waveform in seconds
txsim.DesiredCenterFrequency = 2.45e9; % Center frequency in Hz

% Generate RMC configuration and customize parameters
rmc = lteRMCDL(txsim.RC);
rmc.NCellID = txsim.NCellID;
rmc.NFrame = txsim.NFrame;
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

OSF = 2;

eNodeBOutput = resample(eNodeBOutput,OSF,1);

% Scale the signal for better power output and cast to int16. This is the
% native format for the SDR hardware. Since we are transmitting the same
% signal in a loop, we can do the cast once to save processing time.
powerScaleFactor = 0.9;
eNodeBOutput = eNodeBOutput.*(1/max(abs(eNodeBOutput))*powerScaleFactor);
eNodeBOutput = int16(eNodeBOutput*2^15);

%% Transmit and Receive using MATLAB libiio
rx = adi.ADRV9009.Rx;
tx = adi.ADRV9009.Tx;
tx.EnableCyclicBuffers = true;
tx.AttenuationChannel0 = -10;
tx.uri = ip;
rx.uri = ip;
rx.SamplesPerFrame = length(eNodeBOutput)*3;

rssi1 = 0;
rssi2 = 0;

tx(eNodeBOutput);

% Flush buffers
for i = 1:40
    rx();
end
fprintf('Receiving Data Block\n');
Rx = double(rx());
fprintf('Transmission and reception finished\n');

%% Post Processing of Captured Data

% Remove AGC convergence
Rx = Rx(floor(length(Rx)*0.25):end);

Rx = resample(Rx,1,OSF);

% Call LTE Reciever Function
[plots]=LTEReceiver(Rx,samplingrate,configuration);