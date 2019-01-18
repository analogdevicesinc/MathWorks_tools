classdef AD9363Tests < HardwareTests
    
    properties
        uri = 'ip:192.168.2.1';
        author = 'ADI';
    end
    
    methods(TestClassSetup)
        % Check hardware connected
        function CheckForHardware(testCase)
            Device = @()adi.AD9363.Rx;
            testCase.CheckDevice('ip',Device,testCase.uri(4:end),false);
        end
    end
    
    methods (Static)
        function estFrequency(data,fs)
            nSamp = length(data);
            FFTRxData  = fftshift(10*log10(abs(fft(data))));
            df = fs/nSamp;  freqRangeRx = (-fs/2:df:fs/2-df).'/1000;
            plot(freqRangeRx, FFTRxData);
        end
    end
    
    methods (Test)
        
        function testAD9363Rx(testCase)
            % Test Rx DMA data output
            rx = adi.AD9363.Rx('uri',testCase.uri);
            rx.channelCount = 2;
            [out, valid] = rx();
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end
        
        function testAD9363LoOutOfRange(testCase)
            rx = adi.AD9363.Rx();
            testCase.verifyError(@LoOutOfRange,?MException);
            function LoOutOfRange
                rx.CenterFrequency = 5e9;
            end
        end
        
        function testAD9363RxWithTxDDS(testCase)
            % Test DDS output
            tx = adi.AD9363.Tx('uri',testCase.uri);
            tx.DataSource = 'DDS';
            toneFreq = 5e5;
            tx.DDSFrequencies = repmat(toneFreq,2,4);
            tx.AttenuationChannel0 = -10;
            tx();
            pause(1);
            rx = adi.AD9363.Rx('uri',testCase.uri);
            rx.channelCount = 2;
            rx.kernelBuffersCount = 1;
            for k=1:10
                valid = false;
                while ~valid
                    [out, valid] = rx();
                end
            end
            rx.release();

%             plot(real(out));
%             testCase.estFrequency(out,rx.SamplingRate);
            freqEst = meanfreq(double(real(out)),rx.SamplingRate);

            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(freqEst,toneFreq,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
            
        end
        
        function testAD9363RxWithTxData(testCase)
            % Test Tx DMA data output
            amplitude = 2^15; frequency = 0.12e6;
            swv1 = dsp.SineWave(amplitude, frequency);
            swv1.ComplexOutput = true;
            swv1.SamplesPerFrame = 1e4*10;
            swv1.SampleRate = 3e6;
            y = swv1();
            
            tx = adi.AD9363.Tx('uri',testCase.uri);
            tx.DataSource = 'DMA';
            tx.EnableCyclicBuffers = true;
            tx.AttenuationChannel0 = -10;
            tx(y);
            rx = adi.AD9363.Rx('uri',testCase.uri);
            rx.channelCount = 2;
            rx.kernelBuffersCount = 1;
            for k=1:10
                valid = false;
                while ~valid
                    [out, valid] = rx();
                end
            end
            rx.release();

%             plot(real(out));
%             testCase.estFrequency(out,rx.SamplingRate);
            freqEst = meanfreq(double(real(out)),rx.SamplingRate);
            
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(freqEst,frequency,'RelTol',0.01,...
                'Frequency of ML tone unexpected')
        end
    end
    
end

