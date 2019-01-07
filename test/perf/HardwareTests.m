classdef HardwareTests < LTETests
    
    properties
        SamplingRate = 1e6;
        author = 'MathWorks';
        uri = 'usb:0';
    end
    
    methods(Static)
        
        function saveToJSON(filename,data)
            jsonStr = jsonencode(data);
            filename = fullfile('logs',filename);
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
                sdrTransmitter.uri = testCase.uri;
                sdrTransmitter.SamplingRate = txConfig.SamplingRate;
                sdrTransmitter.EnableCyclicBuffers = true;
                sdrTransmitter.AttenuationChannel0 = txConfig.Gain;
                sdrTransmitter(dataTX);
            end
            
            %% RX
            samplesPerFrame = length(dataTX)*10;
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
            else
                sdrReceiver.uri = testCase.uri;
                sdrReceiver.SamplingRate = rxConfig.SamplingRate;
            end
            
            % SDR Capture
            fprintf('\nStarting a new RF capture.\n\n')
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

        
        function CheckDevice(testCase,type,Dev,ip,istx)
            
            try
                switch type
                    case 'usb'
                        d = Dev();
                    case 'ip'
                        if strcmp(testCase.author,'MathWorks')
                            d= Dev();
                            d.IPAddress = ip;
                        else
                            d= Dev();
                            d.uri = ['ip:',ip];
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
            
            runs = 10;
            
            %% Device specific config
            % TX
            txConfig = struct;
            txConfig.Dev = DeviceTx;
            txConfig.SamplingRate = testCase.SamplingRate;
            txConfig.Gain = -10;
            txConfig.ChannelMapping = 1;
            % RX
            rxConfig = txConfig;
            rxConfig.GainSource = 'AGC Slow Attack';
            rxConfig.Dev = DeviceRx;
            
            %% Run test
            evmMeanResults = zeros(length(Frequencies),runs);
            evmPeakResults = zeros(length(Frequencies),runs);
            evmMeanResultsStd = zeros(size(Frequencies));
            evmPeakResultsStd = zeros(size(Frequencies));
            
            logs = [];
            
            removeIndxs = [];
            for indx = 1:length(Frequencies)
                txConfig.CenterFrequency = Frequencies(indx);
                rxConfig.CenterFrequency = Frequencies(indx);
                evmResults = zeros(runs,2);
                removeRuns = [];
                for k=1:runs
                    try
                        s = repmat('#',1,10);
                        fprintf('%s\nLO frequency %d (%d of %d) | Run %d of %d\n%s\n',...
                            s,Frequencies(indx),indx,length(Frequencies),...
                            k,runs,s);
                        % TX
                        [eNodeBOutput, config] = testCase.TransmitterLTE(name);
                        % Hardware
                        burstCaptures = testCase.SDRToSDR(rxConfig,txConfig,eNodeBOutput);
                        % RX
                        evmResults(k,:) = testCase.ReceiverLTE(name, config, burstCaptures,eNodeBOutput);
                    catch ME
                        warning(['Run failure at run ',num2str(k),', will remove in post processing']);
                        removeRuns = [removeRuns;k]; %#ok<AGROW>
                    end
                end
                evmResults(removeRuns,:) = [];
                if isempty(evmResults)
                    removeIndxs = [removeIndxs; indx]; %#ok<AGROW>
                    warning(['Loop failure at loop ',num2str(indx),', will remove in post processing']);
                    continue;
                end
                evmMeanResults(indx,:) = evmResults(:,1);
                evmPeakResults(indx,:) = evmResults(:,2);
                evmMeanResultsStd(indx) = std(evmResults(:,1));
                evmPeakResultsStd(indx) = std(evmResults(:,2));
                
                % Log
                for k = 1:size(evmResults,1)
                    data = struct;
                    data.testname = testname;
                    data.testdate = datestr(now);
                    data.Frequency = Frequencies(indx);
                    data.evmMeanResults = evmResults(k,1);
                    data.evmPeakResults = evmResults(k,2);
                    ml = ver('MATLAB'); data.matlab_version = ml.Release(2:end-1);
                    logs = [logs;data]; %#ok<AGROW>
                end
                
            end
            
            % Remove failed test cases
            evmMeanResults(removeIndxs,:) = [];
            evmPeakResults(removeIndxs,:) = [];
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
            errorbar(Frequencies./1e9, mean(evmMeanResults,2),evmMeanResultsStd);
            xlabel('LO Frequency (GHz)');
            ylabel('EVM % Mean');
            figure(fig2);
            errorbar(Frequencies./1e9, mean(evmPeakResults,2),evmPeakResultsStd);
            xlabel('LO Frequency (GHz)');
            ylabel('EVM % Peak');
            testCase.verifyEmpty([], ...
                FigureDiagnostic(fig1,'Formats',{'png'},'Prefix',[testname,'_MeanEVM_']))
            testCase.verifyEmpty([], ...
                FigureDiagnostic(fig2,'Formats',{'png'},'Prefix',[testname,'_PeakEVM_']))
            
            
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
            [data, logs] = testCase.SDRLoopbackLTEEVMTest('R4',Frequencies,DeviceTx,DeviceRx,testname);
            
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
            [data, logs] = testCase.SDRLoopbackLTEEVMTest('R4',Frequencies,DeviceTx,DeviceRx,testname);
            
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
            [data,logs] = testCase.SDRLoopbackLTEEVMTest('R4',Frequencies,DeviceTx,DeviceRx,testname);
            
            %% Log data
            json = [testname,'_',num2str(int32(now)),'.json'];
            %testCase.saveToJSON(json, data);
            testCase.saveToJSONExtended(json, logs);
            
        end
        
    end
    
end
