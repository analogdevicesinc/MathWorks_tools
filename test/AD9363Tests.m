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
        
        function testAD9363AGCSettings(testCase)
            rx = adi.AD9363.Rx('uri',testCase.uri);
            % Update AGC settings
            rx.CustomAGC = uint32(1);
            rx.AttackDelay = uint32(47);      
            rx.PeakOverloadWaitTime = uint32(20);
            rx.AGCLockLevel = uint32(101);
            rx.DecStepSizeFullTableCase3 = uint32(5);
            rx.ADCLargeOverloadThresh = uint32(199);
            rx.ADCSmallOverloadThresh = uint32(21);
            rx.DecStepSizeFullTableCase2 = uint32(5);
            rx.DecStepSizeFullTableCase1 = uint32(12);
            rx.LargeLMTOverloadThresh = uint32(12);
            rx.SmallLMTOverloadThresh = uint32(11);
            rx.SettlingDelay = uint32(4);
            rx.EnergyLostThresh = uint32(47);
            rx.LowPowerThresh = uint32(34);
            rx.IncrementGainStep = uint32(4);
            rx.FAGCLockLevelGainIncreaseUpperLimit = uint32(63);
            rx.FAGCLPThreshIncrementTime = uint32(102);
            rx.DecPowMeasurementDuration = uint32(7);
            
            rx();
            % Read AGC settings from hardware
            rAttackDelay = ReadFromRegister(rx, 'AttackDelay');
            testCase.verifyEqual(rAttackDelay,rx.AttackDelay,'Unexpected value for PeakOverloadWaitTime returned');
            rPeakOverloadWaitTime = ReadFromRegister(rx, 'PeakOverloadWaitTime');
            testCase.verifyEqual(rPeakOverloadWaitTime,rx.PeakOverloadWaitTime,'Unexpected value for PeakOverloadWaitTime returned');
            rAGCLockLevel = ReadFromRegister(rx, 'AGCLockLevel');
            testCase.verifyEqual(rAGCLockLevel,rx.AGCLockLevel,'Unexpected value for AGCLockLevel returned');
            rDecStepSizeFullTableCase3 = ReadFromRegister(rx, 'DecStepSizeFullTableCase3');
            testCase.verifyEqual(rDecStepSizeFullTableCase3,rx.DecStepSizeFullTableCase3,'Unexpected value for DecStepSizeFullTableCase3 returned');
            rADCLargeOverloadThresh = ReadFromRegister(rx, 'ADCLargeOverloadThresh');
            testCase.verifyEqual(rADCLargeOverloadThresh,rx.ADCLargeOverloadThresh,'Unexpected value for ADCLargeOverloadThresh returned');
            rADCSmallOverloadThresh = ReadFromRegister(rx, 'ADCSmallOverloadThresh');
            testCase.verifyEqual(rADCSmallOverloadThresh,rx.ADCSmallOverloadThresh,'Unexpected value for ADCSmallOverloadThresh returned');
            rDecStepSizeFullTableCase2 = ReadFromRegister(rx, 'DecStepSizeFullTableCase2');
            testCase.verifyEqual(rDecStepSizeFullTableCase2,rx.DecStepSizeFullTableCase2,'Unexpected value for DecStepSizeFullTableCase2 returned');
            rDecStepSizeFullTableCase1 = ReadFromRegister(rx, 'DecStepSizeFullTableCase1');
            testCase.verifyEqual(rDecStepSizeFullTableCase1,rx.DecStepSizeFullTableCase1,'Unexpected value for DecStepSizeFullTableCase1 returned');
            rLargeLMTOverloadThresh = ReadFromRegister(rx, 'LargeLMTOverloadThresh');
            testCase.verifyEqual(rLargeLMTOverloadThresh,rx.LargeLMTOverloadThresh,'Unexpected value for LargeLMTOverloadThresh returned');
            rSmallLMTOverloadThresh = ReadFromRegister(rx, 'SmallLMTOverloadThresh');
            testCase.verifyEqual(rSmallLMTOverloadThresh,rx.SmallLMTOverloadThresh,'Unexpected value for SmallLMTOverloadThresh returned');
            rSettlingDelay = ReadFromRegister(rx, 'SettlingDelay');
            testCase.verifyEqual(rSettlingDelay,rx.SettlingDelay,'Unexpected value for SettlingDelay returned');
            rEnergyLostThresh = ReadFromRegister(rx, 'EnergyLostThresh');
            testCase.verifyEqual(rEnergyLostThresh,rx.EnergyLostThresh,'Unexpected value for EnergyLostThresh returned');
            rLowPowerThresh = ReadFromRegister(rx, 'LowPowerThresh');
            testCase.verifyEqual(rLowPowerThresh/2,rx.LowPowerThresh,'Unexpected value for LowPowerThresh returned');
            rIncrementGainStep = ReadFromRegister(rx, 'IncrementGainStep');
            testCase.verifyEqual(rIncrementGainStep,rx.IncrementGainStep,'Unexpected value for IncrementGainStep returned');
            rFAGCLockLevelGainIncreaseUpperLimit = ReadFromRegister(rx, 'FAGCLockLevelGainIncreaseUpperLimit');
            testCase.verifyEqual(rFAGCLockLevelGainIncreaseUpperLimit,rx.FAGCLockLevelGainIncreaseUpperLimit,'Unexpected value for FAGCLockLevelGainIncreaseUpperLimit returned');
            rFAGCLPThreshIncrementTime = ReadFromRegister(rx, 'FAGCLPThreshIncrementTime');
            testCase.verifyEqual(rFAGCLPThreshIncrementTime,rx.FAGCLPThreshIncrementTime,'Unexpected value for FAGCLPThreshIncrementTime returned');
            rDecPowMeasurementDuration = ReadFromRegister(rx, 'DecPowMeasurementDuration');
            testCase.verifyEqual(rDecPowMeasurementDuration,rx.DecPowMeasurementDuration,'Unexpected value for DecPowMeasurementDuration returned');
            
            rx.release();
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

