classdef DAQ2Tests < HardwareTests
    
    properties
        uri = 'ip:192.168.3.2';
        author = 'ADI';
    end
    
    methods(TestClassSetup)
        % Check hardware connected
        function CheckForHardware(testCase)
            Device = @()adi.ADRV9009.Rx;
            testCase.CheckDevice('ip',Device,testCase.uri(4:end),false);
        end
    end
    
    methods (Test)
        
        function testDAQ2Rx(testCase)    
            % Test Rx DMA data output
            rx = adi.DAQ2.Rx('uri',testCase.uri);
            rx.channelCount = 2;
            [out, valid] = rx();
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end
        
        function testDAQ2RxWithTxDDS(testCase)
            % Test DDS output
            tx = adi.DAQ2.Tx('uri',testCase.uri);
            tx.DataSource = 'DDS';
            toneFreq = 45e6;
            tx.DDSFrequencies = repmat(toneFreq,2,4);
            tx();
            pause(1);
            rx = adi.DAQ2.Rx('uri',testCase.uri);
            rx.channelCount = 2;
            valid = false;
            for k=1:10
                [out, valid] = rx();
            end
            rx.release();
            
%             plot(real(out));
            freqEst = meanfreq(double(real(out)),rx.SamplingRate);

            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(freqEst,toneFreq,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
        end
        
        function testDAQ2RxWithTxData(testCase)
            % Test Tx DMA data output
            amplitude = 2^15; frequency = 40e6;
            swv1 = dsp.SineWave(amplitude, frequency);
            swv1.ComplexOutput = true;
            swv1.SamplesPerFrame = 2^20;
            swv1.SampleRate = 1e9;
            y = swv1();
            
            tx = adi.DAQ2.Tx('uri',testCase.uri);
            tx.DataSource = 'DMA';
            tx.EnableCyclicBuffers = true;
            tx(y);
            rx = adi.DAQ2.Rx('uri',testCase.uri);
            rx.channelCount = 2;
            for k=1:10
                [out, valid] = rx();
            end
            rx.release();
            
%             plot(real(out));
            freqEst = meanfreq(double(real(out)),rx.SamplingRate);
            
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(freqEst,frequency,'RelTol',0.01,...
                'Frequency of ML tone unexpected')
        end
    end
    
end

