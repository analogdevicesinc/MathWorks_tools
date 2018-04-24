%clc;
radioIP = 'ip:192.168.3.2';
%% Writers
% Frequency Recovery Loop Bandwidth
w1 = matlabshared.libiio.aximm.write('uri',radioIP);
w1.AddressOffset = hex2dec('100');
w1.HardwareDataType='int16';
% Equalizer Step Size
w2 = matlabshared.libiio.aximm.write('uri',radioIP);
w2.AddressOffset = hex2dec('104');
w2.HardwareDataType='int16';
% IQ Scope Selection
w3 = matlabshared.libiio.aximm.write('uri',radioIP);
w3.AddressOffset = hex2dec('108');
w3.HardwareDataType='int8';
% Debug Status Signal Selection
w4 = matlabshared.libiio.aximm.write('uri',radioIP);
w4.AddressOffset = hex2dec('10C');
w4.HardwareDataType='int8';
% Bypass Equalizer
w5 = matlabshared.libiio.aximm.write('uri',radioIP);
w5.AddressOffset = hex2dec('114');
w5.HardwareDataType='int8';
% Enable Packet Decode
w6 = matlabshared.libiio.aximm.write('uri',radioIP);
w6.AddressOffset = hex2dec('118');
w6.HardwareDataType='int8';
% Set Packet Detection Threshold
w7 = matlabshared.libiio.aximm.write('uri',radioIP);
w7.AddressOffset = hex2dec('11C');
w7.HardwareDataType='int8';
% Single Packet TX Toggle
w8 = matlabshared.libiio.aximm.write('uri',radioIP);
w8.AddressOffset = hex2dec('120');
w8.HardwareDataType='int8';
% Constant Transmit Enable
w9 = matlabshared.libiio.aximm.write('uri',radioIP);
w9.AddressOffset = hex2dec('124');
w9.HardwareDataType='int8';
% Loopback IP
w10 = matlabshared.libiio.aximm.write('uri',radioIP);
w10.AddressOffset = hex2dec('12C');
w10.HardwareDataType='int8';
% Channel coding bypass
w11 = matlabshared.libiio.aximm.write('uri',radioIP);
w11.AddressOffset = hex2dec('130');
w11.HardwareDataType='int8';

%% Readers
% Packets Received Count
r1 = matlabshared.libiio.aximm.read('uri',radioIP);
r1.AddressOffset = hex2dec('140');

%% Writes
EnableRXDecode = int8(0);
w6(EnableRXDecode);

LoopBW = int16(10); %[1 128] Valid
w1(LoopBW);

EQmu = int16(300); % Value Inverted internally
w2(EQmu);

Scope = int8(3); % [1 4] Valid
w3(Scope);

ByPassEQ = int8(1); % [0 1] Valid
w5(ByPassEQ);

PDThreshold = int8(10); % [0 inf] Valid
w7(PDThreshold);

% Packet Transmit
w8(int8(1));w8(int8(0)); % Transmit 1
ConstantTX = int8(0);
w9(ConstantTX);

IPLoopback = int8(1); % [0=IP loopback, 1=RF]
w10(IPLoopback);

ChannelCodingBypass = int8(0);
w11(ChannelCodingBypass);

pause(1);
EnableRXDecode = int8(1);
w6(EnableRXDecode);
% %% Continuously read registers
% clc;
% for k=1:1
%     % Check Timing PLL lock
%     Error = int8(0);% Select Error index of interest
%     w4(Error);
%     TimingLocked = r1();
%     % Check peaks found by detector
%     Error = int8(1);% Select Error index of interest
%     w4(Error);
%     PeaksFound = r1();
%     % Check Frequency PLL lock
%     Error = int8(2);% Select Error index of interest
%     w4(Error);
%     FreqLoopLock = r1();
%     % Header failures
%     Error = int8(3);% Select Error index of interest
%     w4(Error);
%     HeaderFailures = r1();
%     % CRC errors
%     Error = int8(4);% Select Error index of interest
%     w4(Error);
%     CRCErrors = r1();
%     % Packets Recovered
%     Error = int8(5);% Select Error index of interest
%     w4(Error);
%     PacketsRecovered = r1();
%     % Last Payload Length
%     Error = int8(6);% Select Error index of interest
%     w4(Error);
%     LastPayloadLength = r1();
%     % Display
%     table(PacketsRecovered,CRCErrors,HeaderFailures,...
%         PeaksFound,TimingLocked,FreqLoopLock,LastPayloadLength)
%     pause(1);
% end
% 
% 
% 
