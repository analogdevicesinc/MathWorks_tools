% Test Tx DDS output
uri = 'ip:192.168.2.1';

%% Tx set up
tx = adi.DAQ2.Tx('uri',uri);
tx.DataSource = 'DDS';
toneFreq = 45e6;
tx.DDSFrequencies = repmat(toneFreq,2,4);
tx();

%% Rx set up
rx = adi.DAQ2.Rx('uri',uri);

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
