classdef AD9361Tests < matlab.unittest.TestCase
    
    properties
        uri = 'ip:192.168.2.1';
    end
    
    methods (Test)
        
        function testAD9361Rx(testCase)    
            % Test Rx DMA data output
            rx = adi.AD9361.Rx('uri',testCase.uri);
            rx.channelCount = 2;
            [out, valid] = rx();
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end
        
        function testAD9361RxWithTxDDS(testCase)
            % Test DDS output
            tx = adi.AD9361.Tx('uri',testCase.uri);
            tx.DataSource = 'DDS';
            tx.DDSFrequencies = [5,5,5,5].*1e3;
            tx.Attenuation = -50;
            tx();
            pause(1);
            rx = adi.AD9361.Rx('uri',testCase.uri);
            rx.channelCount = 2;
            valid = false;
            for k=1:10
                [out, valid] = rx();
            end
            plot(real(out));
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end
        
        function testAD9361RxWithTxData(testCase)
            % Test Tx DMA data output
            amplitude = 2^15; frequency = 0.12e6;
            swv1 = dsp.SineWave(amplitude, frequency);
            swv1.ComplexOutput = true;
            swv1.SamplesPerFrame = 1e4*10;
            swv1.SampleRate = 3e6;
            y = swv1();
            
            tx = adi.AD9361.Tx('uri',testCase.uri);
            tx.DataSource = 'DMA';
            tx.SamplesPerFrame = length(y);
            tx.EnableCyclicBuffers = true;
            tx(y);
            rx = adi.AD9361.Rx('uri',testCase.uri);
            rx.channelCount = 2;
            for k=1:10
                [out, valid] = rx();
            end
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end
    end
    
end

