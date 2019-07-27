% Test Tx DMA data output
amplitude = 2^15; frequency = 20e6;
swv1 = dsp.SineWave(amplitude, frequency);
swv1.ComplexOutput = true;
swv1.SamplesPerFrame = 2^20;
swv1.SampleRate = 122880000;
y1 = swv1();

amplitude = 2^15; frequency = 10e6;
swv1 = dsp.SineWave(amplitude, frequency);
swv1.ComplexOutput = true;
swv1.SamplesPerFrame = 2^20;
swv1.SampleRate = 122880000;
y2 = swv1();

uri = 'ip:analog';
fc = 1e9;

%% Tx set up
tx = adi.AD9371.Tx('uri',uri);
tx.CenterFrequency = fc;
tx.EnableCustomProfile = true;
tx.CustomProfileFileName = 'profile_TxBW100_ORxBW100_RxBW100.txt';
tx.DataSource = 'DMA';
tx.EnableCyclicBuffers = true;
tx.AttenuationChannel0 = -10;
tx.EnabledChannels = [1 2];
tx([y1,y2]);

%% Rx set up
rx = adi.AD9371.Rx('uri',uri);
rx.CenterFrequency = fc;
rx.EnabledChannels = [1 2];

%% Run
for k=1:20
    valid = false;
    while ~valid
        [out, valid] = rx();
    end
end
rx.release();
tx.release();

%% Plot
nSamp = length(out);
fs = tx.SamplingRate;
FFTRxData1  = fftshift(10*log10(abs(fft(out(:,1)))));
FFTRxData2  = fftshift(10*log10(abs(fft(out(:,2)))));
df = fs/nSamp;  freqRangeRx = (-fs/2:df:fs/2-df).'/1e6;
subplot(2,1,1);
plot(freqRangeRx, FFTRxData1);
xlabel('Frequency (MHz)');ylabel('Amplitude (dB)');grid on;
subplot(2,1,2);
plot(freqRangeRx, FFTRxData2);
xlabel('Frequency (MHz)');ylabel('Amplitude (dB)');grid on;
