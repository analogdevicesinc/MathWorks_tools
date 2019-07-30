function [txWaveform,Rs,fc] = genBeacon(SSID)

beaconInterval = 100; % In Time units (TU)
% beaconInterval = 1; % In Time units (TU)
% band = 5;             % Band, 5 or 2.4 GHz
band = 2.4;             % Band, 5 or 2.4 GHz
% chNum = 52;           % Channel number, corresponds to 5260MHz
chNum = 11;           % Channel number, corresponds to 5260MHz
bitsPerByte = 8;      % Number of bits in 1 byte

% Create Beacon frame-body configuration object
frameBodyConfig = wlanMACManagementConfig;
frameBodyConfig.BeaconInterval = beaconInterval;  % Beacon Interval in Time units (TUs)
frameBodyConfig.SSID = SSID;                      % SSID (Name of the network)
dsElementID = 3;                                  % DS Parameter IE element ID
dsInformation = dec2hex(chNum, 2);                % DS Parameter IE information
frameBodyConfig = frameBodyConfig.addIE(dsElementID, dsInformation);  % Add DS Parameter IE to the configuration

% Create Beacon frame configuration object
beaconFrameConfig = wlanMACFrameConfig('FrameType', 'Beacon');
beaconFrameConfig.ManagementConfig = frameBodyConfig;

% Generate Beacon frame
[beacon, mpduLength] = wlanMACFrame(beaconFrameConfig);

% Convert the mpdu bytes in hexa-decimal format to bits
beacon = hex2dec(beacon);
bits = reshape(de2bi(beacon, bitsPerByte)', [], 1);

% Calculate center frequency for the given band and channel number
fc = helperWLANChannelFrequency(chNum, band);

%% Create IEEE 802.11 Beacon Packet
cfgNonHT = wlanNonHTConfig;           % Create a wlanNonHTConfig object
cfgNonHT.PSDULength = mpduLength;     % Set the PSDU length in bytes
txWaveform = wlanWaveformGenerator(bits, cfgNonHT, 'IdleTime', beaconInterval*1024e-6);
% txWaveform = wlanWaveformGenerator(bits, cfgNonHT, 'IdleTime',0);
Rs = wlanSampleRate(cfgNonHT);           % Get the input sampling rate

%% Save Waveform to File
% txWaveform = repmat(txWaveform,10,1);
BBW = comm.BasebandFileWriter('nonHTBeaconPacketTransmitted.bb', Rs, fc);
BBW(txWaveform);
release(BBW);



