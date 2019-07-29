
SSID = 'ADI-BEACON';
osf = 1; % OverSampling factor
fc2 = 1e9;
% sdr = 'AD936x';
sdr = 'Pluto';


%% Generate Beacon Data
[txWaveform,Rs,fc] = genBeacon(SSID);

%% Send out SDR
tx = sdrtx(sdr);
% tx.ShowAdvancedProperties = true;
% tx.BypassUserLogic = true;
tx.BasebandSampleRate = Rs*osf;
% tx.CenterFrequency = fc;
tx.CenterFrequency = fc2;
% Set transmit gain
tx.Gain = -30;
% Resample transmit waveform
txWaveform = resample(txWaveform, osf, 1);
% Transmit over-the-air
% txWaveform = 0.9*2^15*(txWaveform)./max(abs(txWaveform));
transmitRepeat(tx, txWaveform);
%%
for g=1:1
% Receive
rx = sdrrx(sdr);
% rx.CenterFrequency = fc+0;%40e3;
rx.CenterFrequency = fc2;
% rx.SamplesPerFrame = 2^15;
rx.SamplesPerFrame = length(txWaveform)*5;
rx.BasebandSampleRate = Rs*osf;
% rx.GainSource = 'AGC Fast Attack';
rx.GainSource = 'Manual';
rx.Gain = 3;
fprintf('\nStarting a new RF capture.\n\n')
for k=1:20
    len = 0;
    while len == 0
        % Store one LTE frame worth of samples
        [dataRX,len] = rx();
    end
end
disp('Done collection');
clear rx tx
% dataRX = resample(double(dataRX),1,osf);

% Save Waveform to File
BBW = comm.BasebandFileWriter('nonHTBeaconPacketReceived.bb', Rs, fc);
BBW(dataRX);
release(BBW);
disp(length(dataRX)/Rs);

ReceiverFloatWLAN;

end

