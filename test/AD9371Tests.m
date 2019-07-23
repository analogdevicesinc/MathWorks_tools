classdef AD9371Tests < HardwareTests
    
    properties
        uri = 'ip:analog';
        SamplingRateRX = 122.88e6;
        author = 'ADI';
    end
    
    methods(TestClassSetup)
        % Check hardware connected
        function CheckForHardware(testCase)
            Device = @()adi.AD9371.Rx;
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
        
        function testAD9371Rx(testCase)
            % Test Rx DMA data output
            rx = adi.AD9371.Rx('uri',testCase.uri);
            rx.EnabledChannels = 1;
            [out, valid] = rx();
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end
        
        function testAD9371Obs(testCase)
            % Test Rx DMA data output
            rx = adi.AD9371.ORx('uri',testCase.uri);
            rx.RFPortSelect = 'ORX1_TX_LO';
            rx.EnabledChannels = 1;
            [out, valid] = rx();
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end
        
        function testAD9371SNF(testCase)
            % Test Rx DMA data output
            rx = adi.AD9371.ORx('uri',testCase.uri);
            rx.RFPortSelect = 'SN_A';
            rx.EnabledChannels = 1;
            [out, valid] = rx();
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end
        
        function testAD9371ObsPortCycle(testCase)
            % Test Rx DMA data output
            rx = adi.AD9371.ORx('uri',testCase.uri);
            rx.RFPortSelect = 'SN_A';
            rx.EnabledChannels = 1;
            
            ports = { ...
                'ORX1_TX_LO','ORX2_TX_LO',...
                'ORX1_SN_LO','ORX2_SN_LO',...
                'SN_A','SN_B','SN_C'};
            
            for k = 1:length(ports)
                rx.RFPortSelect = ports{k};
                for tries = 1:10
                    [out, valid] = rx();
                    if valid
                        testCase.verifyGreaterThan(sum(abs(double(out))),0);
                        break
                    end
                end
            end
            
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end
        
        function testAD9371RxCustomProfile1(testCase)
            % Test Rx custom profiles
            rx = adi.AD9371.Rx('uri',testCase.uri);
            rx.EnabledChannels = 1;
            rx.EnableCustomProfile = true;
            rx.CustomProfileFileName = ...
                'profile_TxBW50_ORxBW50_RxBW50.txt';
            [out, valid] = rx();
            rxSampleRate = rx.getAttributeLongLong('voltage0',...
                'sampling_frequency',false);
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(rxSampleRate,int64(61440000),...
                'Invalid sample rate after profile write');
        end
        
        function testAD9371RxCustomProfile2(testCase)
            % Test Rx custom profiles
            rx = adi.AD9371.Rx('uri',testCase.uri);
            rx.EnabledChannels = 1;
            rx.EnableCustomProfile = true;
            rx.CustomProfileFileName = ...
                'profile_TxBW100_ORxBW100_RxBW100.txt';
            [out, valid] = rx();
            rxSampleRate = rx.getAttributeLongLong('voltage0',...
                'sampling_frequency',false);
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(rxSampleRate,int64(122880000),...
                'Invalid sample rate after profile write');
        end
        
        function testAD9371TxCustomProfile1(testCase)
            % Test Rx custom profiles
            tx = adi.AD9371.Tx('uri',testCase.uri);
            tx.EnabledChannels = 1;
            tx.EnableCustomProfile = true;
            tx.CustomProfileFileName = ...
                'profile_TxBW50_ORxBW50_RxBW50.txt';
            valid = tx(complex(randn(1024,1)));
            txSampleRate = tx.getAttributeLongLong('voltage0',...
                'sampling_frequency',true);
            tx.release();
            testCase.verifyTrue(valid);
            testCase.verifyEqual(txSampleRate,int64(61440000),...
                'Invalid sample rate after profile write');
        end
        
        function testAD9371TxCustomProfile2(testCase)
            % Test Rx custom profiles
            tx = adi.AD9371.Tx('uri',testCase.uri);
            tx.EnabledChannels = 1;
            tx.EnableCustomProfile = true;
            tx.CustomProfileFileName = ...
                'profile_TxBW100_ORxBW100_RxBW100.txt';
            valid = tx(complex(randn(1024,1)));
            txSampleRate = tx.getAttributeLongLong('voltage0',...
                'sampling_frequency',true);
            tx.release();
            testCase.verifyTrue(valid);
            testCase.verifyEqual(txSampleRate,int64(122880000),...
                'Invalid sample rate after profile write');
        end
        
        function testAD9371RxWithTxDDS(testCase)
            % Test assumes RX1 and TX1 are connected through a cable
            % Test DDS output
            tx = adi.AD9371.Tx('uri',testCase.uri);
            tx.DataSource = 'DDS';
            toneFreq = 30e6;
            tx.DDSFrequencies = repmat(toneFreq,2,4);
            tx.DDSScales = zeros(2,4);
            tx.DDSScales(1,1:2) = [1 1];
            tx.DDSPhases = zeros(2,4);
            tx.DDSPhases(1,1) = 90000;
            tx.AttenuationChannel0 = -10;
            tx.EnableCustomProfile = true;
            tx.CustomProfileFileName = ...
                'profile_TxBW100_ORxBW100_RxBW100.txt';
            tx();
            pause(1);
            rx = adi.AD9371.Rx('uri',testCase.uri);
            rx.EnabledChannels = 1;
            rx.kernelBuffersCount = 1;
            for k=1:10
                valid = false;
                while ~valid
                    [out, valid] = rx();
                end
            end

%             plot(real(out));
%             testCase.estFrequency(out,testCase.SamplingRateRX);
            rxSampleRate = rx.getAttributeLongLong('voltage0',...
                'sampling_frequency',false);
            freqEst = meanfreq(double(real(out)),rxSampleRate);

            rx.release();
            tx.release();
            
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(freqEst,toneFreq,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
            
        end
        
        function testAD9371RxWithTxData(testCase)
            % Test assumes RX1 and TX1 are connected through a cable
            % Test Tx DMA data output
            amplitude = 2^15; frequency = 20e6;
            swv1 = dsp.SineWave(amplitude, frequency);
            swv1.ComplexOutput = true;
            swv1.SamplesPerFrame = 2^20;
            swv1.SampleRate = testCase.SamplingRateRX;
            y = swv1();
            
            tx = adi.AD9371.Tx('uri',testCase.uri);
            tx.DataSource = 'DMA';
            tx.EnableCyclicBuffers = true;
            tx.AttenuationChannel0 = -10;
            tx.EnableCustomProfile = true;
            tx.CustomProfileFileName = ...
                'profile_TxBW100_ORxBW100_RxBW100.txt';
            tx(y);
            rx = adi.AD9371.Rx('uri',testCase.uri);
            rx.EnabledChannels = 1;
            rx.kernelBuffersCount = 1;
            for k=1:20
                valid = false;
                while ~valid
                    [out, valid] = rx();
                end
            end

%             plot(real(out));
%             testCase.estFrequency(out,testCase.SamplingRateRX);
            rxSampleRate = rx.getAttributeLongLong('voltage0',...
                'sampling_frequency',false);
            freqEst = meanfreq(double(real(out)),rxSampleRate);

            rx.release();
            tx.release();
            
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(freqEst,frequency,'RelTol',0.01,...
                'Frequency of ML tone unexpected')
        end
    end
    
end

