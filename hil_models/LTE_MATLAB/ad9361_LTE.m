function [plots,rssi1,rssi2]=ad9361_LTE(ip,LTEmode)

clc;

%% Pick up LTE parameters according to LTE Mode

if strcmp(LTEmode,'LTE1.4') == 1
    configuration = 'R.4';
    samplingrate = 1.92e6;
    bandwidth = 1.08e6;
    fir_data_file = 'LTE1p4_MHz.ftr';
elseif strcmp(LTEmode,'LTE3') == 1
    configuration = 'R.5';
    samplingrate = 3.84e6;
    bandwidth = 2.7e6;
    fir_data_file = 'LTE3_MHz.ftr';
elseif strcmp(LTEmode,'LTE5') == 1
    configuration = 'R.6';
    samplingrate = 7.68e6;
    bandwidth = 4.5e6;
    fir_data_file = 'LTE5_MHz.ftr';
elseif strcmp(LTEmode,'LTE10') == 1
    configuration = 'R.7';
    samplingrate = 15.36e6;
    bandwidth = 9e6;
    fir_data_file = 'LTE10_MHz.ftr';
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
rmc.OCNG = 'On'; % Add noise to unallocated PDSCH resource elements

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

%% Transmit and Receive using MATLAB libiio

% System Object Configuration
s = iio_sys_obj_matlab; % MATLAB libiio Constructor
s.ip_address = ip;
s.dev_name = 'ad9361';
s.in_ch_no = 2;
s.out_ch_no = 2;
s.in_ch_size = length(eNodeBOutput);
s.out_ch_size = length(eNodeBOutput)*4;

s = s.setupImpl();

% Configure the FIR filter on AD9361
s.writeFirData(fir_data_file);

input = cell(1, s.in_ch_no + length(s.iio_dev_cfg.cfg_ch));
output = cell(1, s.out_ch_no + length(s.iio_dev_cfg.mon_ch));

% Set the attributes of AD9361
input{s.getInChannel('RX_LO_FREQ')} = 2.45e9;
input{s.getInChannel('RX_SAMPLING_FREQ')} = samplingrate;
input{s.getInChannel('RX_RF_BANDWIDTH')} = bandwidth;
input{s.getInChannel('RX1_GAIN_MODE')} = 'slow_attack';
input{s.getInChannel('RX1_GAIN')} = 0;
input{s.getInChannel('RX2_GAIN_MODE')} = 'slow_attack';
input{s.getInChannel('RX2_GAIN')} = 0;
input{s.getInChannel('TX_LO_FREQ')} = 2.45e9;
input{s.getInChannel('TX_SAMPLING_FREQ')} = samplingrate;
input{s.getInChannel('TX_RF_BANDWIDTH')} = bandwidth;

% Keep transmiting and receiving the LTE signal
fprintf('Starting transmission at Fs = %g MHz\n',txsim.SamplingRate/1e6);
for i = 1:4
    fprintf('Transmitting Data Block %i ...\n',i);
    input{1} = real(eNodeBOutput);
    input{2} = imag(eNodeBOutput);
    output = stepImpl(s, input);
    fprintf('Data Block %i Received...\n',i);
end
fprintf('Transmission and reception finished\n');

% Read the RSSI attributes of both channels
rssi1 = output{s.getOutChannel('RX1_RSSI')};
rssi2 = output{s.getOutChannel('RX2_RSSI')};

s.releaseImpl();

%% Post Processing of Captured Data

I = output{1};
Q = output{2};
Rx = I+1i*Q;

% Call LTE Reciever Function
[plots]=LTEReceiver(Rx,samplingrate,configuration);