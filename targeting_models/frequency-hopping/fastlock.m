clear all
uri = 'ip:192.168.86.35';

%% Turn on DDS
tx = adi.AD9361.Tx('uri',uri);
tx.DataSource = 'DDS';
tx.SamplingRate = 20e6;
tx.RFBandwidth = 20e6;
toneFreq = 4e6;
tx.DDSFrequencies = repmat(toneFreq,2,4);
tx.AttenuationChannel0 = -10;
tx();
pause(1);
%% Set up fastlock profiles
freqs = 2.4e9+(1:8).*1e6;
for f = 0:length(freqs)-1
    % Update LO
    tx.CenterFrequency = freqs(f+1);
    pause(1);
    % Save profile
    tx.setAttributeLongLong('altvoltage1','fastlock_store',int64(f),true,8);
    fprintf('Saving profile at LO %d\n',freqs(f+1));
end
% Set pin control mode
tx.setDebugAttributeBool('adi,tx-fastlock-pincontrol-enable',1);
tx.setAttributeLongLong('altvoltage1','fastlock_recall',int64(0),true,8);
%% Configure Hop mode
h = FrequencyHopper;
h.uri = uri;
h.DwellSamples = 20000;
h.HoppingEnable = true;
h();
%% Capture
rx = adi.AD9361.Rx('uri',uri);
rx.SamplingRate = 20e6;
rx.CenterFrequency = 2.4e9+0.5e6;
rx.RFBandwidth = 20e6;
rx.SamplesPerFrame = 1e6;
rx.channelCount = 2;
rx.kernelBuffersCount = 1;
for k=1:10
    valid = false;
    while ~valid
        [out, valid] = rx();
    end
end
rx.release();
%% Plot
spectrogram(double(out),128,80,100,20e6,'yaxis','centered')
view(-77,72)
shading interp
colorbar off

