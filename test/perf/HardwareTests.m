classdef HardwareTests < LTETests
    
    properties
        SamplingRate = 1e6;
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
        
        function dataRX = SDRToSDR(rxConfig, txConfig, dataTX)
            
            %% TX
            sdrTransmitter = txConfig.Dev();
            sdrTransmitter.BasebandSampleRate = txConfig.SamplingRate;
            sdrTransmitter.CenterFrequency = txConfig.CenterFrequency;
            sdrTransmitter.ShowAdvancedProperties = true;
            sdrTransmitter.Gain = txConfig.Gain;
            sdrTransmitter.ChannelMapping = txConfig.ChannelMapping;
            
            sdrTransmitter.transmitRepeat(dataTX);
            
            %% RX
            samplesPerFrame = length(dataTX)*10;
            sdrReceiver = rxConfig.Dev();
            sdrReceiver.BasebandSampleRate = rxConfig.SamplingRate;
            sdrReceiver.CenterFrequency = rxConfig.CenterFrequency;
            sdrReceiver.OutputDataType = 'double';
            sdrReceiver.ChannelMapping = rxConfig.ChannelMapping;
            sdrReceiver.SamplesPerFrame = samplesPerFrame;
            
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
            
        end
    end
    
    methods
        
        function CheckDevice(testCase,type,Dev,ip,istx)
            
            try
                switch type
                    case 'usb'
                        d = Dev();
                    case 'ip'
                        d= Dev('RadioID',['ip:',ip]);
                    otherwise
                        error('Unknown interface type');
                end
                if istx
                    d(complex(randn(1024,1),randn(1024,1)));
                else
                    d();
                end
                
            catch
                assumeFail(testCase);
            end
            
        end
        
        function data = SDRLoopbackLTEEVMTest(testCase,name,Frequencies,DeviceTx,DeviceRx,testname)
            
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
            evmMeanResults = zeros(size(Frequencies));
            evmPeakResults = zeros(size(Frequencies));
            evmMeanResultsStd = zeros(size(Frequencies));
            evmPeakResultsStd = zeros(size(Frequencies));
            
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
                    catch
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
            errorbar(Frequencies./1e9, evmMeanResults,evmMeanResultsStd);
            xlabel('LO Frequency (GHz)');
            ylabel('EVM % Mean');
            figure(fig2);
            errorbar(Frequencies./1e9, evmPeakResults,evmPeakResultsStd);
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
            testname = 'LTE_R4_Pluto';
            
            %% Check hardware connected
            testCase.CheckDevice('usb',DeviceTx,[],true);
            testCase.CheckDevice('usb',DeviceRx,[],false);
            
            %% Run Test
            data = testCase.SDRLoopbackLTEEVMTest('R4',Frequencies,DeviceTx,DeviceRx,testname);
            
            %% Log data
            json = [testname,'_',num2str(int32(now)),'.json'];
            testCase.saveToJSON(json, data);
            
        end
        
        function LTE_R4_RFSOM(testCase)
            
            %% Test configs
            Frequencies = (0.4:0.1:5).*1e9;
            DeviceTx = @()sdrtx('ADI RF SOM');
            DeviceRx = @()sdrrx('ADI RF SOM');
            testname = 'LTE_R4_RFSOM';
            
            %% Check hardware connected
            testCase.CheckDevice('ip',DeviceTx,'192.168.3.2',true);
            testCase.CheckDevice('ip',DeviceRx,'192.168.3.2',false);
            
            %% Run Test
            data = testCase.SDRLoopbackLTEEVMTest('R4',Frequencies,DeviceTx,DeviceRx,testname);
            
            %% Log data
            json = [testname,'_',num2str(int32(now)),'.json'];
            testCase.saveToJSON(json, data);
            
        end
        
    end
    
end
