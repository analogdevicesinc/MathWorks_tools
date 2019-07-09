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
            
            % read default settings
            rx();
            default_settings.AttackDelay = ReadFromRegister(rx, 'AttackDelay');
            default_settings.PeakOverloadWaitTime = ReadFromRegister(rx, 'PeakOverloadWaitTime');
            default_settings.AGCLockLevel = ReadFromRegister(rx, 'AGCLockLevel');
            default_settings.DecStepSizeFullTableCase3 = ReadFromRegister(rx, 'DecStepSizeFullTableCase3');
            default_settings.ADCLargeOverloadThresh = ReadFromRegister(rx, 'ADCLargeOverloadThresh');
            default_settings.ADCSmallOverloadThresh = ReadFromRegister(rx, 'ADCSmallOverloadThresh');
            default_settings.DecStepSizeFullTableCase2 = ReadFromRegister(rx, 'DecStepSizeFullTableCase2');
            default_settings.DecStepSizeFullTableCase1 = ReadFromRegister(rx, 'DecStepSizeFullTableCase1');
            default_settings.LargeLMTOverloadThresh = ReadFromRegister(rx, 'LargeLMTOverloadThresh');
            default_settings.SmallLMTOverloadThresh = ReadFromRegister(rx, 'SmallLMTOverloadThresh');
            default_settings.SettlingDelay = ReadFromRegister(rx, 'SettlingDelay');
            default_settings.EnergyLostThresh = ReadFromRegister(rx, 'EnergyLostThresh');
            default_settings.LowPowerThresh = ReadFromRegister(rx, 'LowPowerThresh');
            default_settings.IncrementGainStep = ReadFromRegister(rx, 'IncrementGainStep');
            default_settings.FAGCLockLevelGainIncreaseUpperLimit = ReadFromRegister(rx, 'FAGCLockLevelGainIncreaseUpperLimit');
            default_settings.FAGCLPThreshIncrementTime = ReadFromRegister(rx, 'FAGCLPThreshIncrementTime');
            default_settings.DecPowMeasurementDuration = ReadFromRegister(rx, 'DecPowMeasurementDuration');
            rx.release();
            
            % Update AGC settings
            rx.CustomAGC = 1;
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
            
            % Read AGC settings from hardware, 
            % check that they are equal 
            fnames = fieldnames(default_settings);
            for ii = 1:length(fnames)
                ret_val = ReadFromRegister(rx, fnames{ii});
                if (strcmp(fnames{ii},'LowPowerThresh'))
                    testCase.verifyEqual(ret_val/2,rx.(fnames{ii}),['Unexpected value for ',fnames{ii},' returned']);
                else
                    testCase.verifyEqual(ret_val,rx.(fnames{ii}),['Unexpected value for ',fnames{ii},' returned']);
                end
            end
            rx.release();
            
            % then, assign default values
            for ii = 1:length(fnames)
                if (strcmp(fnames{ii},'LowPowerThresh'))
                    rx.(fnames{ii}) = default_settings.(fnames{ii})/2;
                else
                    rx.(fnames{ii}) = default_settings.(fnames{ii});
                end
            end
            rx();
            for ii = 1:length(fnames)
                ret_val = ReadFromRegister(rx, fnames{ii});
                if (strcmp(fnames{ii},'LowPowerThresh'))
                    testCase.verifyEqual(ret_val/2,rx.(fnames{ii}),['Unexpected value for ',fnames{ii},' returned']);
                else
                    testCase.verifyEqual(ret_val,rx.(fnames{ii}),['Unexpected value for ',fnames{ii},' returned']);
                end
            end
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

