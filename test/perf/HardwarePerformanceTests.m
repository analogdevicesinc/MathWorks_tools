classdef HardwarePerformanceTests < LTETests & DeviceRuntime ...
        & Calibration
    
    properties
        author = 'MathWorks';
        LoopIterationsPerFrequency = 10;
        RXBufferSize = 2^18;
        EnabledCalibration = true;
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
        
        function InstrumentReset(~)
            g = instrfind; %#ok<NASGU>
            instrreset;
        end
        
        function CheckTestInput(~,Tx,Rx)
            if ~isfield(Tx,'Device')
                error('Missing Tx Device');
            end
            if ~isfield(Tx,'SamplingRate')
                error('Missing Tx SamplingRate');
            end
            if ~isfield(Tx,'Gain')
                error('Missing Tx Gain');
            end
            if ~isfield(Tx,'Address')
                error('Missing Tx Address');
            end
            
            if ~isfield(Rx,'Device')
                error('Missing Rx Device');
            end
            if ~isfield(Rx,'SamplingRate')
                error('Missing Rx SamplingRate');
            end
            if ~isfield(Rx,'Gain')
                error('Missing Rx Gain');
            end
            if ~isfield(Rx,'Address')
                error('Missing Rx Address');
            end
            if ~isfield(Rx,'GainMode')
                error('Missing Rx GainMode');
            end
        end
        
        function [data,logs] = SDRLoopbackLTEEVMTest(testCase,...
                LTEMode,...
                Frequencies,Tx,Rx,...
                ExtendedTxParams,ExtendedRxParams,...
                testname)
            
            import matlab.unittest.diagnostics.FigureDiagnostic
            import matlab.unittest.diagnostics.FileArtifact;
            
            % Check inputs to make sure everything is defined
            testCase.CheckTestInput(Tx,Rx);
            
            runs = testCase.LoopIterationsPerFrequency;
            
            %% Run test
            evmMeanResults = zeros(size(Frequencies));
            evmPeakResults = zeros(size(Frequencies));
            evmMeanResultsStd = zeros(size(Frequencies));
            evmPeakResultsStd = zeros(size(Frequencies));
            
            logs = [];
            
            removeIndxs = [];
            for indx = 1:length(Frequencies)
                
                Tx.CenterFrequency = fix(Frequencies(indx));
                Rx.CenterFrequency = fix(Frequencies(indx));
                evmResults = zeros(runs,2);
                removeRuns = [];
                
                % Calibrate
                if testCase.EnabledCalibration
                    testCase.Calibrate(Tx,Rx,ExtendedTxParams,ExtendedRxParams);
                end
                
                for k=1:runs
                    try
                        s = repmat('#',1,10);
                        testCase.log(1,sprintf('%s\nLO frequency %d (%d of %d) | Run %d of %d\n%s\n',...
                            s,Frequencies(indx),indx,length(Frequencies),...
                            k,runs,s));
                        % Instrument Reset
                        testCase.InstrumentReset();
                        % TX
                        [eNodeBOutput, config] = testCase.TransmitterLTE(LTEMode);
                        % Hardware
                        burstCaptures = testCase.DeviceToDevice(...
                            Tx,Rx,...
                            ExtendedTxParams,ExtendedRxParams,...
                            eNodeBOutput);
                        % RX
                        evmResults(k,:) = testCase.ReceiverLTE(LTEMode, config, burstCaptures,eNodeBOutput);
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
            
            %% Required test configs
            testCase.author = 'MathWorks';
            testname = 'LTE_R4_Pluto_MW';
            
            Frequencies = (0.4:0.1:5).*1e9;
            Tx = struct;
            Tx.Device = @()sdrtx('Pluto');
            Tx.Gain = -20;
            Tx.Address = 'usb:0';
            Tx.SamplingRate = 1e6;
            
            Rx = struct;
            Rx.Device = @()sdrrx('Pluto');
            Rx.GainMode = 'AGC Slow Attack';
            Rx.Gain = NaN;
            Rx.Address = 'usb:0';
            Rx.SamplingRate = 1e6;
            
            ExtendedTxParams = [];
            ExtendedRxParams = [];
            
            %% Check hardware connected
            testCase.CheckDevice('usb',Tx.Device,[],true);
            testCase.CheckDevice('usb',Rx.Device,[],false);
            
            %% Run Test
            [~, logs] = testCase.SDRLoopbackLTEEVMTest('LTE10',Frequencies,...
                Tx,Rx,ExtendedTxParams,ExtendedRxParams,testname);
            
            %% Log data
            json = [testname,'_',num2str(int32(now)),'.json'];
            testCase.saveToJSONExtended(json, logs);
            
        end
        
        function LTE_R4_RFSOM(testCase)
            
            if ismac
                % RF SOM is not supported on OSX from MathWorks
                assumeFail(testCase);
            end
            
            %% Required test configs
            testCase.author = 'MathWorks';
            testname = 'LTE_R4_RFSOM_MW';
            
            Frequencies = (0.4:0.1:5).*1e9;
            Tx = struct;
            Tx.Device = @()sdrtx('ADI RF SOM');
            Tx.Gain = -20;
            Tx.Address = 'ip:192.168.4.1';
            Tx.SamplingRate = 1e6;
            
            Rx = struct;
            Rx.Device = @()sdrrx('ADI RF SOM');
            Rx.GainMode = 'AGC Slow Attack';
            Rx.Gain = NaN;
            Rx.Address = 'ip:192.168.4.1';
            Rx.SamplingRate = 1e6;
            
            ExtendedTxParams = [];
            ExtendedRxParams = [];
            
            %% Check hardware connected
            testCase.CheckDevice('ip',Tx.Device,Tx.Address(4:end),true);
            testCase.CheckDevice('ip',Rx.Device,Rx.Address(4:end),false);
            
            %% Run Test
            [~, logs] = testCase.SDRLoopbackLTEEVMTest('R4',Frequencies,...
                Tx,Rx,ExtendedTxParams,ExtendedRxParams,testname);
            
            %% Log data
            json = [testname,'_',num2str(int32(now)),'.json'];
            testCase.saveToJSONExtended(json, logs);
            %testCase.saveToJSON(json, data);
            
        end
        
        function LTE_R4_AD9361(testCase)
            
            %% Required test configs
            testCase.author = 'ADI';
            testname = 'LTE_R4_AD9361_ADI';
            
            Frequencies = (0.4:0.1:5).*1e9;
            Tx = struct;
            Tx.Device = @()adi.AD9361.Tx;
            Tx.Gain = -20;
            Tx.Address = 'ip:192.168.4.1';
            Tx.SamplingRate = 1e6;
            
            Rx = struct;
            Rx.Device = @()adi.AD9361.Rx;
            Rx.GainMode = 'slow_attack';
            Rx.Gain = NaN;
            Rx.Address = 'ip:192.168.4.1';
            Rx.SamplingRate = 1e6;
            
            ExtendedTxParams = [];
            ExtendedRxParams = [];
            
            %% Check hardware connected
            testCase.CheckDevice('ip',Tx.Device,Tx.Address(4:end),true);
            testCase.CheckDevice('ip',Rx.Device,Rx.Address(4:end),false);
            
            %% Run Test
            [~, logs] = testCase.SDRLoopbackLTEEVMTest('R4',Frequencies,...
                Tx,Rx,ExtendedTxParams,ExtendedRxParams,testname);
            
            %% Log data
            json = [testname,'_',num2str(int32(now)),'.json'];
            %testCase.saveToJSON(json, data);
            testCase.saveToJSONExtended(json, logs);
            
        end
        
        function LTE_R4_Two_Pluto(testCase)
            
            import matlab.unittest.plugins.DiagnosticsRecordingPlugin
            
            %% Required test configs
            testCase.author = 'ADI';
            testname = 'LTE_LTE10_Two_Pluto_MW';
            
            Frequencies = (0.4:0.1:5).*1e9;
            Tx = struct;
            Tx.Device = @()adi.Pluto.Tx();
            Tx.Gain = -20;
            Tx.Address = 'usb:2.13.5';
            Tx.SamplingRate = 1e6;
            
            Rx = struct;
            Rx.Device = @()adi.Pluto.Rx();
            Rx.GainMode = 'slow_attack';
            Rx.Gain = NaN;
            Rx.Address = 'usb:3.3.5';
            Rx.SamplingRate = 1e6;
            
            Tx.CustomFilterFilename = 'LTE10_MHz.ftr';
            Rx.CustomFilterFilename = 'LTE10_MHz.ftr';
            
            ExtendedTxParams = [];
            ExtendedRxParams = [];
            
            %% Check hardware connected
            testCase.CheckDevice('usb',Tx.Device,Tx.Address(5:end),true);
            testCase.CheckDevice('usb',Rx.Device,Rx.Address(5:end),false);
            
            %% Run Test
            data = testCase.SDRLoopbackLTEEVMTest('R4',Frequencies,...
                Tx,Rx,ExtendedTxParams,ExtendedRxParams,testname);
            
            %% Log data
            json = [testname,'_',num2str(int32(now)),'.json'];
            testCase.saveToJSON(json, data);
            
        end
        
        function LTE10_ADRV9009(testCase)
            
            import matlab.unittest.plugins.DiagnosticsRecordingPlugin
            
            %% Required test configs
            testname = 'LTE10_ADRV9009';
            testCase.author = 'ADI';
            Frequencies = (0.4:0.1:5).*1e9;
            
            Tx = struct;
            Tx.Device = @()adi.ADRV9009.Tx();
            Tx.Gain = -30;
            Tx.Address = 'ip:192.168.86.248';
            Tx.SamplingRate = 1e6;
            
            Rx = struct;
            Rx.Device = @()adi.ADRV9009.Rx();
            Rx.GainMode = 'slow_attack';
            Rx.Gain = NaN;
            Rx.Address = 'ip:192.168.86.248';
            Rx.SamplingRate = 1e6;
            
            % ADRV9009 Specific parameters
            Tx.CustomProfileFilename = 'SOM.ftr';
            Rx.CustomProfileFilename = 'SOM.ftr';
            
            ExtendedTxParams = [];
            ExtendedRxParams = [];
            
            %% Check hardware connected
            testCase.CheckDevice('ip',Tx.Device,Tx.Address(4:end),true);
            testCase.CheckDevice('ip',Rx.Device,Rx.Address(4:end),false);
            
            %% Run Test
            data = testCase.SDRLoopbackLTEEVMTest('LTE10',Frequencies,...
                Tx,Rx,ExtendedTxParams,ExtendedRxParams,testname);
            
            %% Log data
            json = [testname,'_',num2str(int32(now)),'.json'];
            testCase.saveToJSON(json, data);
            
        end
        
        function LTE10_ADRV9009ZU11EG(testCase)
            
            import matlab.unittest.plugins.DiagnosticsRecordingPlugin
            
            %% Test configs
            Frequencies = (0.4:0.1:5).*1e9;
            DeviceTx = @()adi.ADRV9009.Tx();
            DeviceRx = @()adi.ADRV9009.Rx();
            testname = 'LTE_LTE10_ADRV9009';
            testCase.author = 'ADI';
            ip = '192.168.86.248';
            testCase.uriTX = ['ip:',ip];
            testCase.uriRX = ['ip:',ip];
            testCase.EnableCustomProfile = true;
            testCase.ProfileFilename = 'SOM.ftr';
            testCase.GainControlMode = 'slow_attack';
            %% Check hardware connected
            testCase.CheckDevice('ip',DeviceTx,ip,true);
            testCase.CheckDevice('ip',DeviceRx,ip,false);
            
            %% Run Test
            data = testCase.SDRLoopbackLTEEVMTest('LTE10',Frequencies,DeviceTx,DeviceRx,testname);
            
            %% Log data
            json = [testname,'_',num2str(int32(now)),'.json'];
            testCase.saveToJSON(json, data);
            
        end
        
        function LTE10_MXG_To_ADRV9009ZU11EG(testCase)
            
            import matlab.unittest.plugins.DiagnosticsRecordingPlugin
            
            %% Test configs
            Frequencies = (0.4:0.1:5).*1e9;
            DeviceTx = @()N5182B();
            DeviceRx = @()adi.ADRV9009.Rx();
            testname = 'LTE_LTE10_ADRV9009ZU11EG';
            testCase.author = 'ADI';
            testCase.uriTX = '10.66.98.244';
            testCase.uriRX = 'ip:10.66.98.57';
            testCase.EnableCustomFilter = true;
            testCase.FilterFilename = 'SOM.ftr';
            testCase.GainControlMode = 'slow_attack';
            
            testCase.RxSamplingRate = 122.88e6;
            testCase.TxSamplingRate = 122.88e6;
            % Extended configs
            TxConfig = struct;
            TxConfig.OutputPower = -20;
            RxConfig = [];
            
            %% Check hardware connected
            %             testCase.CheckDevice('ip',DeviceRx,testCase.uriRX(4:end),false);
            
            %% Run Test
            data = testCase.SDRLoopbackLTEEVMTest('LTE10',Frequencies,...
                DeviceTx,DeviceRx,testname,TxConfig,RxConfig);
            
            %% Log data
            json = [testname,'_',num2str(int32(now)),'.json'];
            testCase.saveToJSON(json, data);
            
        end
        
        function LTE10_ADRV9009ZU11EG_To_PXA(testCase)
            
            import matlab.unittest.plugins.DiagnosticsRecordingPlugin
            
            %% Test configs
            Frequencies = (0.4:0.1:5).*1e9;
            DeviceTx = @()adi.ADRV9009.Tx();
            DeviceRx = @()N9030A();
            testname = 'LTE_LTE10_ADRV9009';
            testCase.author = 'ADI';
            testCase.uriTX = 'ip:169.254.189.22';
            testCase.uriRX = '169.254.189.20';
            testCase.EnableCustomProfile = true;
            testCase.ProfileFilename = 'SOM.ftr';
            testCase.TxSamplingRate = 122.88e6;
            testCase.RxSamplingRate = 7.68e6;
            
            %% Check hardware connected
            testCase.CheckDevice('ip',DeviceTx,testCase.uriTX(4:end),true);
            
            %% Run Test
            data = testCase.SDRLoopbackLTEEVMTest('LTE5',Frequencies,DeviceTx,DeviceRx,testname);
            
            %% Log data
            json = [testname,'_',num2str(int32(now)),'.json'];
            testCase.saveToJSON(json, data);
            
        end
        
        function LTE20_MXG_To_PXA(testCase)
            
            import matlab.unittest.plugins.DiagnosticsRecordingPlugin
            
            %% Test configs
            Frequencies = (0.4:0.1:5).*1e9;
            DeviceTx = @()N5182B();
            DeviceRx = @()N9030A();
            testname = 'LTE_LTE10_MXG_PXA';
            testCase.author = 'ADI';
            testCase.uriTX = '169.254.189.21';
            testCase.uriRX = '169.254.189.20';
            testCase.EnableCustomFilter = true;
            
            % Cannot run PXA above 10 MHz
            %             testCase.RxSamplingRate = 15.36e6;
            %             testCase.TxSamplingRate = 15.36e6;
            testCase.RxSamplingRate = 10e6;
            testCase.TxSamplingRate = 10e6;
            
            %% Run Test
            data = testCase.SDRLoopbackLTEEVMTest('LTE10',Frequencies,DeviceTx,DeviceRx,testname);
            
            %% Log data
            json = [testname,'_',num2str(int32(now)),'.json'];
            testCase.saveToJSON(json, data);
            
        end
        
        
    end
    
end
