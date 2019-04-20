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

%% Transmit and Receive using MATLAB libiio

% System Object Configurations
rx = iio_sys_obj_matlab; % MATLAB libiio Constructor
rx.ip_address = ip;
rx.dev_name = 'ad9361';
rx.in_ch_no = 0;
rx.out_ch_no = 2;
rx.in_ch_size = 0;
rx.out_ch_size = length(eNodeBOutput)*5;

rx = rx.setupImpl();

tx = iio_sys_obj_matlab; % MATLAB libiio Constructor
tx.ip_address = ip;
tx.dev_name = 'ad9361';
tx.in_ch_no = 2;
tx.out_ch_no = 0;
tx.in_ch_size = length(eNodeBOutput);
tx.out_ch_size = 0;

tx = tx.setupImpl();

inputTX = cell(1, tx.in_ch_no + length(tx.iio_dev_cfg.cfg_ch));
inputRX = cell(1, rx.in_ch_no + length(rx.iio_dev_cfg.cfg_ch));

% Set the attributes of AD9361
inputTX{tx.getInChannel('RX_LO_FREQ')} = 2.45e9;
inputTX{tx.getInChannel('RX_RF_BANDWIDTH')} = bandwidth;
inputTX{tx.getInChannel('RX1_GAIN_MODE')} = 'slow_attack';
inputTX{tx.getInChannel('RX1_GAIN')} = 0;
inputTX{tx.getInChannel('RX2_GAIN_MODE')} = 'slow_attack';
inputTX{tx.getInChannel('RX2_GAIN')} = 0;
inputTX{tx.getInChannel('TX_LO_FREQ')} = 2.45e9;
inputTX{tx.getInChannel('TX_SAMPLING_FREQ')} = samplingrate;
inputTX{tx.getInChannel('TX_RF_BANDWIDTH')} = bandwidth;

inputRX{rx.getInChannel('RX_LO_FREQ')} = 2.45e9;
inputRX{rx.getInChannel('RX_RF_BANDWIDTH')} = bandwidth;
inputRX{rx.getInChannel('RX1_GAIN_MODE')} = 'slow_attack';
inputRX{rx.getInChannel('RX1_GAIN')} = 0;
inputRX{rx.getInChannel('RX2_GAIN_MODE')} = 'slow_attack';
inputRX{rx.getInChannel('RX2_GAIN')} = 0;
inputRX{rx.getInChannel('TX_LO_FREQ')} = 2.45e9;
inputRX{rx.getInChannel('TX_SAMPLING_FREQ')} = samplingrate;
inputRX{rx.getInChannel('TX_RF_BANDWIDTH')} = bandwidth;

% Configure the FIR filter on AD9361
rx.writeFirData(fir_data_file);
tx.writeFirData(fir_data_file);

% Transmit waveform in cyclic mode
fprintf('Starting transmission at Fs = %g MHz\n',txsim.SamplingRate/1e6);
fprintf('Transmitting Data Block\n');
inputTX{1} = real(eNodeBOutput);
inputTX{2} = imag(eNodeBOutput);
stepImpl(tx, inputTX);

% Flush buffers
for i = 1:20
    stepImpl(rx, inputRX);
end
fprintf('Receiving Data Block\n');
output = stepImpl(rx, inputRX);
fprintf('Transmission and reception finished\n');

% Read the RSSI attributes of both channels
rssi1 = output{rx.getOutChannel('RX1_RSSI')};
rssi2 = output{rx.getOutChannel('RX2_RSSI')};

tx.releaseImpl();
rx.releaseImpl();

%% Post Processing of Captured Data

I = output{1};
Q = output{2};
Rx = I+1i*Q;

% Remove AGC convergence
Rx = Rx(floor(length(Rx)*0.25):end);

% Call LTE Reciever Function
[plots]=LTEReceiver(Rx,samplingrate,configuration);