clear;
clc;

%% Generate LTE-1.4 Signal using LTE System Toolbox

% Check for LST presence
if isempty(ver('lte'))
    error('ad9361_LTE:NoLST','Please install LTE System Toolbox to run this example.');
end

% Generate the LTE signal
txsim.RC = 'R.4';         % Base RMC configuration, 1.4 MHz bandwidth.
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
[eNodeBOutput,txGrid,rmc] = lteRMCDLTool(rmc,trData);
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
s.ip_address = '192.168.10.2';
s.dev_name = 'ad9361';
s.in_ch_no = 2;
s.out_ch_no = 2;
s.in_ch_size = 19200;
s.out_ch_size = 19200*5;

s = s.setupImpl();

input = cell(1, s.in_ch_no + length(s.iio_dev_cfg.cfg_ch));
output = cell(1, s.out_ch_no + length(s.iio_dev_cfg.mon_ch));

% Set the attributes of AD9361
input{s.in_ch_no+1} = 2.45e9;
input{s.in_ch_no+2} = 1.92e6;
input{s.in_ch_no+3} = 1.4e6;
input{s.in_ch_no+4} = 'slow_attack';
input{s.in_ch_no+5} = 0;
input{s.in_ch_no+6} = 'slow_attack';
input{s.in_ch_no+7} = 0;
input{s.in_ch_no+8} = 2.45e9;
input{s.in_ch_no+9} = 1.92e6;
input{s.in_ch_no+10} = 1.4e6;

% Keep transmiting and receiving the LTE signal
fprintf('Starting transmission at Fs = %g MHz\n',txsim.SamplingRate/1e6);
for i = 1:5
    fprintf('Transmitting Data Block %i ...\n',i);
    input{1} = real(eNodeBOutput);
    input{2} = imag(eNodeBOutput);
    output = stepImpl(s, input);
end
fprintf('Transmission finished\n');

% Read the RSSI attributes of both channels
rssi1 = output{s.out_ch_no+1};
rssi2 = output{s.out_ch_no+2};

s.releaseImpl();

%% Post Processing of Caputured Data

I = output{1};
Q = output{2};
Rx = I+1i*Q;

% Plot time-domain I and Q channels
figure % new figure
ax1 = subplot(2,1,1); % top subplot
ax2 = subplot(2,1,2); % bottom subplot

plot(ax1,output{1});
title(ax1,'I');
xlabel('Sample');
ylabel('Amplitude');

plot(ax2,output{2});
title(ax2,'Q');
xlabel('Sample');
ylabel('Amplitude');

% Call LTE Reciever Function
LTEReceiver;