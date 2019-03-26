classdef HardwarePerformanceTests < LTETests
    
    properties
        SamplingRate = 1e6;
        author = 'MathWorks';
        uri = 'usb:0';
        uriRX = 'usb:1';
        uriTX = 'usb:0';
        TxGain = -30;
        EnableCustomFilter = false;
        FilterFilename = '';
        LoopIterationsPerFrequency = 3;
    end

    properties (Hidden)
        RxFrequencyCorrectionFactor = 0;
        CalibrationLoopIterations = 10;
        CalibrationFrequencyToleranceHz = 0.1;
    end
    
    methods(Static)
        
        function saveToJSON(filename,data)
            jsonStr = jsonencode(data);
            filename = fullfile('logs',filename);
            if exist('logs','dir') ~= 7
                mkdir('log');
            end
            fid = fopen(filename, 'w');
            if fid == -1, error('Cannot create JSON file'); end
            fwrite(fid, jsonStr, 'char');
            fclose(fid);
        end

        function saveToJSONExtended(filename,data)
            jsonStr = [];
            for line = 1:length(data)
                jsonStr = [jsonStr newline jsonencode(data(line))]; %#ok<AGROW>
            end
            filename = fullfile('logs',filename);
            fid = fopen(filename, 'w');
            if fid == -1, error('Cannot create JSON file'); end
            fwrite(fid, jsonStr, 'char');
            fclose(fid);
        end
        
    end
    
    methods
        
        function CalibratePluto(testCase,rxConfig,txConfig)
            
            
            [rx,tx] = ConfigureSDRs(testCase, rxConfig, txConfig);   
            
            % Transmit tone at known location
            if strcmpi(testCase.author,'MathWorks')
                fs = tx.BasebandSampleRate;
            else
                fs = tx.SamplingRate;
%                 fs = 15360000;
            end
            centerFreq = rx.CenterFrequency;
            fRef = fix(fs/4);
            N = 1e3;
            s = exp(1j*2*pi*fRef*[0:N-1]'/fs); %#ok<NBRAK>
            s = 0.9*s/max(abs(s)); % Scale signal to avoid clipping in the time domain
            s = int16(s*2^15);
            if strcmpi(testCase.author,'MathWorks')
                transmitRepeat(tx, s);
            else
                tx(s);
            end
            pause(1);
            % Configure RX with additional settings
            nSamp = 1024*1024;
            rx.SamplesPerFrame = nSamp;
            rx.kernelBuffersCount = 1;
            if strcmpi(testCase.author,'MathWorks')
                rx.ShowAdvancedProperties = true;
            end
            
            for loop = 1:testCase.CalibrationLoopIterations
                % Measure tone location
                testCase.log(1,'Collecting data for calibration');
                for k=1:10
                    valid = false;
                    while ~valid
                        [receivedSig, valid] = rx();
                    end
                end
                
                % Estimate tone
                y = fftshift(abs(fft(receivedSig)));
                [~,idx] = max(y);
                fReceived = (max(idx)-nSamp/2)/nSamp*fs;

%                 figure(1);
%                 df = fs/nSamp;  x = (-fs/2:df:fs/2-df).'/1000;
%                 plot(x,10*log10(y))
%                 hold on; stem(x(idx),10*log10(y(idx)),'r'); hold off;
                
                correctionFactor = (fReceived - fRef) / (centerFreq + fRef) * 1e6;
                errorHz = fReceived - fRef;
                                
                if strcmpi(testCase.author,'MathWorks')
                    rx.FrequencyCorrection = rx.FrequencyCorrection + 0.3*correctionFactor;
                    testCase.RxFrequencyCorrectionFactor = rx.FrequencyCorrection;
                else
                    if abs(errorHz) < 20
                        cc = sign(errorHz);
                    else
                        cc = fix(0.3*correctionFactor*100);
                    end
                    v = rx.getDeviceAttributeLongLong('xo_correction') - ...
                        cc;
                    rx.setDeviceAttributeLongLong('xo_correction',v);
                    testCase.RxFrequencyCorrectionFactor = rx.getDeviceAttributeLongLong('xo_correction');%rx.FrequencyCorrection;
                end


                msg = sprintf([...
                    '    Tone Freq: %.6f\n',...
                    'Est Tone Freq: %.6f\n',...
                    '        Error: %.6f\n'],fRef,fReceived,errorHz);
                
                testCase.log(msg);
                if abs(errorHz) < testCase.CalibrationFrequencyToleranceHz
                    testCase.log(1,'Tolerance met... calibration complete');
                    break
                end
                
            end
            
            
        end
        
        function [sdrReceiver,sdrTransmitter] = ConfigureSDRs(testCase, rxConfig, txConfig)
            
            %% TX
            sdrTransmitter = txConfig.Dev();
            sdrTransmitter.CenterFrequency = txConfig.CenterFrequency;
            
            if strcmp(testCase.author,'MathWorks')
                if isprop(sdrTransmitter,'RadioID')
                    sdrTransmitter.RadioID = testCase.uriTX;
                else
                    sdrTransmitter.IPAddress = testCase.uriTX;
                end
                sdrTransmitter.ShowAdvancedProperties = true;
                sdrTransmitter.BasebandSampleRate = txConfig.SamplingRate;
                sdrTransmitter.ChannelMapping = txConfig.ChannelMapping;
                sdrTransmitter.Gain = txConfig.Gain;
            else
                sdrTransmitter.uri = testCase.uriTX;
                sdrTransmitter.SamplingRate = txConfig.SamplingRate;
                sdrTransmitter.EnableCyclicBuffers = true;
                sdrTransmitter.AttenuationChannel0 = txConfig.Gain;
                if testCase.EnableCustomFilter
                    sdrTransmitter.EnableCustomFilter = true;
                    sdrTransmitter.CustomFilterFileName = testCase.FilterFilename;
                end
            end
            
            %% RX
            sdrReceiver = rxConfig.Dev();
            sdrReceiver.CenterFrequency = rxConfig.CenterFrequency;
            
            if strcmp(testCase.author,'MathWorks')
                if isprop(sdrReceiver,'RadioID')
                    sdrReceiver.RadioID = testCase.uriRX;
                else
                    sdrReceiver.IPAddress = testCase.uriRX;
                end
                sdrReceiver.BasebandSampleRate = rxConfig.SamplingRate;
                %sdrReceiver.OutputDataType = 'double';
                sdrReceiver.OutputDataType = 'int16';
                sdrReceiver.ChannelMapping = rxConfig.ChannelMapping;
                sdrReceiver.FrequencyCorrection = ... 
                    testCase.RxFrequencyCorrectionFactor;
            else
                sdrReceiver.uri = testCase.uriRX;
                sdrReceiver.SamplingRate = rxConfig.SamplingRate;
                if testCase.EnableCustomFilter
                    sdrReceiver.EnableCustomFilter = true;
                    sdrReceiver.CustomFilterFileName = testCase.FilterFilename;
                end
            end
        end

        
        function dataRX = SDRToSDR(testCase, rxConfig, txConfig, dataTX)
            
            %% TX
            sdrTransmitter = txConfig.Dev();
            sdrTransmitter.CenterFrequency = txConfig.CenterFrequency;
            
            if strcmp(testCase.author,'MathWorks')
                if isprop(sdrTransmitter,'RadioID')
                    sdrTransmitter.RadioID = testCase.uri;
                else
                    sdrTransmitter.IPAddress = testCase.uri;
                end
                sdrTransmitter.ShowAdvancedProperties = true;
                sdrTransmitter.BasebandSampleRate = txConfig.SamplingRate;
                sdrTransmitter.ChannelMapping = txConfig.ChannelMapping;
                sdrTransmitter.Gain = txConfig.Gain;
                sdrTransmitter.transmitRepeat(dataTX);
            else
                sdrTransmitter.uri = testCase.uriTX;
                sdrTransmitter.SamplingRate = txConfig.SamplingRate;
                sdrTransmitter.EnableCyclicBuffers = true;
                sdrTransmitter.AttenuationChannel0 = txConfig.Gain;
                if testCase.EnableCustomFilter
                    sdrTransmitter.EnableCustomFilter = true;
                    sdrTransmitter.CustomFilterFileName = testCase.FilterFilename;
                end
                sdrTransmitter(dataTX);
            end
            
            %% RX
            samplesPerFrame = 2^18;%length(dataTX)*10;
            sdrReceiver = rxConfig.Dev();
            sdrReceiver.CenterFrequency = rxConfig.CenterFrequency;
            sdrReceiver.SamplesPerFrame = samplesPerFrame;
            
            if strcmp(testCase.author,'MathWorks')
                if isprop(sdrReceiver,'RadioID')
                    sdrReceiver.RadioID = testCase.uri;
                else
                    sdrReceiver.IPAddress = testCase.uri;
                end
                sdrReceiver.BasebandSampleRate = rxConfig.SamplingRate;
                %sdrReceiver.OutputDataType = 'double';
                sdrReceiver.OutputDataType = 'int16';
                sdrReceiver.ChannelMapping = rxConfig.ChannelMapping;
                sdrReceiver.FrequencyCorrection = ... 
                    testCase.RxFrequencyCorrectionFactor;
            else
                sdrReceiver.uri = testCase.uriRX;
                sdrReceiver.SamplingRate = rxConfig.SamplingRate;
                if testCase.EnableCustomFilter
                    sdrReceiver.EnableCustomFilter = true;
                    sdrReceiver.CustomFilterFileName = testCase.FilterFilename;
                end
                sdrReceiver.kernelBuffersCount = 1;
            end
            
            % SDR Capture
            testCase.log(1,'Starting a new RF capture.');
            for k=1:20
                len = 0;
                while len == 0
                    % Store one LTE frame worth of samples
                    [dataRX,len] = sdrReceiver();
                end
            end
            
            sdrTransmitter.release();
            sdrReceiver.release();
            clear sdrTransmitter sdrReceiver
            
            dataRX = double(dataRX)./max(abs(double(dataRX)));
            
            
        end

        
        function CheckDevice(testCase,type,Dev,address,istx)
            
            try
                switch type
                    case 'usb'
                        d = Dev();
                        if ~isempty(address)
                            if strcmp(testCase.author,'MathWorks')
                                d.RadioID = ['usb:',address];
                            else
                                d.uri = ['usb:',address];
                            end
                        end
                    case 'ip'
                        if strcmp(testCase.author,'MathWorks')
                            d= Dev();
                            d.IPAddress = address;
                        else
                            d= Dev();
                            d.uri = ['ip:',address];
                        end
                    otherwise
                        error('Unknown interface type');
                end
                if istx
                    d(complex(randn(1024,1),randn(1024,1)));
                else
                    d();
                end
                
            catch ME
                disp(ME.message);
                assumeFail(testCase);
            end
            
        end
        
        function [data,logs] = SDRLoopbackLTEEVMTest(testCase,name,Frequencies,DeviceTx,DeviceRx,testname)
            
            import matlab.unittest.diagnostics.FigureDiagnostic
            import matlab.unittest.diagnostics.FileArtifact;
            
            runs = testCase.LoopIterationsPerFrequency;
            
            %% Device specific config
            % TX
            txConfig = struct;
            txConfig.Dev = DeviceTx;
            txConfig.SamplingRate = testCase.SamplingRate;
            txConfig.Gain = testCase.TxGain;
            txConfig.ChannelMapping = 1;
            % RX
            rxConfig = txConfig;
            rxConfig.GainSource = 'AGC Slow Attack';
            rxConfig.Dev = DeviceRx;
            
            %% Run test
            evmMeanResults = zeros(size(Frequencies));
            evmPeakResults = zeros(size(Frequencies));
            evmMeanResultsStd = zeros(size(Frequencies));
            evmPeakResultsStd = zeros(size(Frequencies));
            
            logs = [];
            
            removeIndxs = [];
            for indx = 1:length(Frequencies)
                txConfig.CenterFrequency = fix(Frequencies(indx));
                rxConfig.CenterFrequency = fix(Frequencies(indx));
                evmResults = zeros(runs,2);
                removeRuns = [];
                
                % Calibrate
                testCase.CalibratePluto(rxConfig,txConfig)
                
                for k=1:runs
                    try
                        s = repmat('#',1,10);
                        testCase.log(1,sprintf('%s\nLO frequency %d (%d of %d) | Run %d of %d\n%s\n',...
                            s,Frequencies(indx),indx,length(Frequencies),...
                            k,runs,s));
                        % TX
                        [eNodeBOutput, config] = testCase.TransmitterLTE(name);
                        % Hardware
                        burstCaptures = testCase.SDRToSDR(rxConfig,txConfig,eNodeBOutput);
                        % RX
                        evmResults(k,:) = testCase.ReceiverLTE(name, config, burstCaptures,eNodeBOutput);
                    catch ME
                        warning(['Run failure at run ',num2str(k),', will remove in post processing']);
                        disp(ME);
                        removeRuns = [removeRuns;k]; %#ok<AGROW>
                    end
                end
                evmResults(removeRuns,:) = [];
                if isempty(evmResults)
                    removeIndxs = [removeIndxs; indx]; %#ok<AGROW>
                    warning(['Loop failure at loop ',num2str(indx),', will remove in post processing']);
                    continue;
                end
                
                evmMeanResults(indx) = mean(evmResults(:,1));
                evmPeakResults(indx) = mean(evmResults(:,2));
                evmMeanResultsStd(indx) = std(evmResults(:,1));
                evmPeakResultsStd(indx) = std(evmResults(:,2));
                
            end
            
            % Remove failed test cases
            evmMeanResults(removeIndxs) = [];
            evmPeakResults(removeIndxs) = [];
            evmMeanResultsStd(removeIndxs) = [];
            evmPeakResultsStd(removeIndxs) = [];
            Frequencies(removeIndxs) = [];
            
            %% Logs
            data = struct;
            data.testname = testname;
            data.testdate = datestr(now);
            data.Frequencies = Frequencies;
            data.evmMeanResults = evmMeanResults;
            data.evmMeanResultsStd = evmMeanResultsStd;
            data.evmPeakResults = evmPeakResults;
            data.evmPeakResultsStd = evmPeakResultsStd;
            ml = ver('MATLAB'); data.matlab_version = ml.Release(2:end-1);
            
            %% Plots
            fig1 = figure;
            fig2 = figure;
            figure(fig1);
            errorbar(Frequencies./1e9, evmMeanResults, evmMeanResultsStd);
            xlabel('LO Frequency (GHz)');
            ylabel('EVM % Mean');
            figure(fig2);
            errorbar(Frequencies./1e9, evmPeakResults, evmPeakResultsStd);
            xlabel('LO Frequency (GHz)');
            ylabel('EVM % Peak');
            testCase.log(FigureDiagnostic(fig1,'Formats',{'fig'},'Prefix',[testname,'_MeanEVM_']));
            testCase.log(FigureDiagnostic(fig2,'Formats',{'fig'},'Prefix',[testname,'_PeakEVM_']));
            savefig(fig1,['logs/',testname,'_MeanEVM'])
            savefig(fig2,['logs/',testname,'_PeakEVM'])
            
        end
    end
    
    methods(Test)
        
        function LTE_R4_Pluto(testCase)
            
            %% Test configs
            Frequencies = (0.4:0.1:5).*1e9;
            DeviceTx = @()sdrtx('Pluto');
            DeviceRx = @()sdrrx('Pluto');
            testname = 'LTE_R4_Pluto_MW';
            
            %% Check hardware connected
            testCase.CheckDevice('usb',DeviceTx,[],true);
            testCase.CheckDevice('usb',DeviceRx,[],false);
            
            %% Run Test
            [~, logs] = testCase.SDRLoopbackLTEEVMTest('R4',Frequencies,DeviceTx,DeviceRx,testname);
            
            %% Log data
            json = [testname,'_',num2str(int32(now)),'.json'];
            testCase.saveToJSONExtended(json, logs);
            
        end
        
        function LTE_R4_RFSOM(testCase)
            
            if ismac
                % RF SOM is not supported on OSX from MathWorks 
                assumeFail(testCase);
            end
            
            %% Test configs
            Frequencies = (0.4:0.1:5).*1e9;
            DeviceTx = @()sdrtx('ADI RF SOM');
            DeviceRx = @()sdrrx('ADI RF SOM');
            testname = 'LTE_R4_RFSOM_MW';
            testCase.uri = 'ip:192.168.3.2';
            
            %% Check hardware connected
            testCase.CheckDevice('ip',DeviceTx,'192.168.3.2',true);
            testCase.CheckDevice('ip',DeviceRx,'192.168.3.2',false);
            
            %% Run Test
            [~, logs] = testCase.SDRLoopbackLTEEVMTest('R4',Frequencies,DeviceTx,DeviceRx,testname);
            
            %% Log data
            json = [testname,'_',num2str(int32(now)),'.json'];
            testCase.saveToJSONExtended(json, logs);
            %testCase.saveToJSON(json, data);
            
        end
        
        function LTE_R4_AD9361(testCase)
            
            %% Test configs
            Frequencies = (0.4:0.1:5).*1e9;
            DeviceTx = @()adi.AD9361.Tx();
            DeviceRx = @()adi.AD9361.Rx();
            testname = 'LTE_R4_AD9361_ADI';
            testCase.uri = 'ip:192.168.2.1';
            testCase.author = 'ADI';
            
            %% Check hardware connected
            testCase.CheckDevice('ip',DeviceTx,'192.168.2.1',true);
            testCase.CheckDevice('ip',DeviceRx,'192.168.2.1',false);
            
            %% Run Test
            [~,logs] = testCase.SDRLoopbackLTEEVMTest('R4',Frequencies,DeviceTx,DeviceRx,testname);
            
            %% Log data
            json = [testname,'_',num2str(int32(now)),'.json'];
            %testCase.saveToJSON(json, data);
            testCase.saveToJSONExtended(json, logs);
            
        end
        
        function LTE_R4_Two_Pluto(testCase)
            
            import matlab.unittest.plugins.DiagnosticsRecordingPlugin
            
            %% Test configs
            Frequencies = (0.4:0.1:5).*1e9;
            DeviceTx = @()adi.Pluto.Tx();
            DeviceRx = @()adi.Pluto.Rx();
            testname = 'LTE_LTE10_Two_Pluto_MW';
            testCase.author = 'ADI';
            testCase.uriTX = 'usb:2.13.5';
            testCase.uriRX = 'usb:3.3.5';
            testCase.EnableCustomFilter = true;
            testCase.FilterFilename = 'LTE10_MHz.ftr';
                        
            %% Check hardware connected
            testCase.CheckDevice('usb',DeviceTx,'2.13.5',true);
            testCase.CheckDevice('usb',DeviceRx,'3.3.5',false);

            %% Run Test
            data = testCase.SDRLoopbackLTEEVMTest('LTE10',Frequencies,DeviceTx,DeviceRx,testname);
            
            %% Log data
            json = [testname,'_',num2str(int32(now)),'.json'];
            testCase.saveToJSON(json, data);
            
        end
        
    end
    
end
