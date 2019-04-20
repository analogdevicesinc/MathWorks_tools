% Test Tx DMA data output
amplitude = 2^15; frequency = 0.12e6;
swv1 = dsp.SineWave(amplitude, frequency);
swv1.ComplexOutput = true;
swv1.SamplesPerFrame = 1e4*10;
swv1.SampleRate = 3e6;
y = swv1();

uri = 'ip:192.168.2.1';
fc = 1e9;

%% Tx set up
tx = adi.AD9361.Tx('uri',uri);
tx.CenterFrequency = fc;
tx.DataSource = 'DMA';
tx.EnableCyclicBuffers = true;
tx.AttenuationChannel0 = -30;
tx(y);

%% Rx set up
rx = adi.AD9361.Rx('uri',uri);
rx.CenterFrequency = fc;

%% Run
for k=1:10
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
FFTRxData  = fftshift(10*log10(abs(fft(out))));
df = fs/nSamp;  freqRangeRx = (-fs/2:df:fs/2-df).'/1000;
plot(freqRangeRx, FFTRxData);
xlabel('Frequency (kHz)');ylabel('Amplitude (dB)');grid on;
