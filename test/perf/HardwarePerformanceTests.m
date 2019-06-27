classdef HardwarePerformanceTests < HardwareTestGeneric
    
    methods(Test)
        
        function LTE_R4_Pluto(testCase)
            
            %% Required test configs
            testCase.author = 'MathWorks';
            testname = 'LTE_R4_Pluto_MW';
            
            Frequencies = (0.4:0.1:5).*1e9;
            Tx = struct;
            Tx.Device = @()sdrtx('Pluto');
            Tx.Gain = -30;
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
        
        function LTE_R4_Pluto_ADI_CustomFilter(testCase)
            
            %% Required test configs
            testCase.author = 'ADI';
            testname = 'LTE_R4_PLUTO_ADI_CustomFilter';
            
            Frequencies = (0.4:0.1:5).*1e9;
            Tx = struct;
            Tx.Device = @()adi.Pluto.Tx;
            Tx.Gain = -20;
            Tx.Address = 'ip:192.168.2.1';
            Tx.SamplingRate = 10e6;
            
            Rx = struct;
            Rx.Device = @()adi.Pluto.Rx;
            Rx.GainMode = 'slow_attack';
            Rx.Gain = NaN;
            Rx.Address = 'ip:192.168.2.1';
            Rx.SamplingRate = 10e6;
            
            ExtendedTxParams.EnableCustomFilter = true;
            ExtendedTxParams.CustomFilterFileName = 'LTE5_MHz.ftr';
            ExtendedRxParams.EnableCustomFilter = true;
            ExtendedRxParams.CustomFilterFileName = 'LTE5_MHz.ftr';
            
            %% Check hardware connected
            testCase.CheckDevice('ip',Tx.Device,Tx.Address(4:end),true);
            testCase.CheckDevice('ip',Rx.Device,Rx.Address(4:end),false);
            
            %% Run Test
            [~, logs] = testCase.SDRLoopbackLTEEVMTest('LTE5',Frequencies,...
                Tx,Rx,ExtendedTxParams,ExtendedRxParams,testname);
            
            %% Log data
            json = [testname,'_',num2str(int32(now)),'.json'];
            %testCase.saveToJSON(json, data);
            testCase.saveToJSONExtended(json, logs);
            
        end
        
        function LTE_R4_Pluto_ADI_SETBBRATE(testCase)
            
            %% Required test configs
            testCase.author = 'ADI';
            testname = 'LTE_R4_PLUTO_ADI_CustomFilter';
            
            Frequencies = (0.4:0.1:5).*1e9;
            Tx = struct;
            Tx.Device = @()adi.Pluto.Tx;
            Tx.Gain = -20;
            Tx.Address = 'ip:192.168.2.1';
            Tx.SamplingRate = 10e6;
            
            Rx = struct;
            Rx.Device = @()adi.Pluto.Rx;
            Rx.GainMode = 'slow_attack';
            Rx.Gain = NaN;
            Rx.Address = 'ip:192.168.2.1';
            Rx.SamplingRate = 10e6;
            
            ExtendedTxParams.RFBandwidth = 5e6*1.5;
            ExtendedRxParams.RFBandwidth = 5e6*1.5;
            
            %% Check hardware connected
            testCase.CheckDevice('ip',Tx.Device,Tx.Address(4:end),true);
            testCase.CheckDevice('ip',Rx.Device,Rx.Address(4:end),false);
            
            %% Run Test
            [~, logs] = testCase.SDRLoopbackLTEEVMTest('LTE5',Frequencies,...
                Tx,Rx,ExtendedTxParams,ExtendedRxParams,testname);
            
            %% Log data
            json = [testname,'_',num2str(int32(now)),'.json'];
            %testCase.saveToJSON(json, data);
            testCase.saveToJSONExtended(json, logs);
            
        end
        
        function LTE_R4_Pluto_DSG3060(testCase)
            
            %% Required test configs
            testCase.author = 'MathWorks';
            testname = 'LTE_R4_Pluto_MW_DSG3060';
            
            Frequencies = (0.4:0.1:0.45).*1e9;
            Tx = struct;
            Tx.Device = @()DSG3060();
            Tx.Gain = -10;
            Tx.Address = 'USB0::0x1AB1::0x0992::DSG3A172400066::INSTR';
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
            Tx.Address = 'ip:192.168.2.1';
            Tx.SamplingRate = 1e6;
            
            Rx = struct;
            Rx.Device = @()adi.AD9361.Rx;
            Rx.GainMode = 'slow_attack';
            Rx.Gain = NaN;
            Rx.Address = 'ip:192.168.2.1';
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
        
        function LTE10_PSG_To_ADRV9009(testCase)
            
            import matlab.unittest.plugins.DiagnosticsRecordingPlugin
            
            %% Test configs
%             Frequencies = (0.4:0.1:5).*1e9;
            Frequencies = (3:0.5:5.5).*1e9;
            testname = 'LTE10_ADRV9009_SOM_RX_PSG';
            testCase.author = 'ADI';
            
%             DeviceTx = @()E8267D();
%             DeviceRx = @()adi.ADRV9009.Rx();
%             testname = 'LTE_LTE10_ADRV9009ZU11EG';
%             testCase.author = 'ADI';
%             testCase.uriTX = '192.168.1.11';
%             testCase.uriRX = 'ip:192.168.1.2';
%             testCase.EnableCustomFilter = true;
%             testCase.FilterFilename = 'SOM.ftr';
%             testCase.GainControlMode = 'slow_attack';
%             
%             testCase.RxSamplingRate = 122.88e6;
%             testCase.TxSamplingRate = 122.88e6;
%             % Extended configs
%             TxConfig = struct;
%             TxConfig.OutputPower = -20;
%             RxConfig = [];
            %%
            testCase.LoopIterationsPerFrequency = 4;
            testCase.EnabledCalibration = false;
            
            Tx = struct;
            Tx.Device = @()E8267D();
            Tx.Gain = -5;
            Tx.Address = '192.168.1.11';
            Tx.SamplingRate = 15.36e6*4;
            
            Rx = struct;
            Rx.Device = @()adi.ADRV9009.Rx();
%             Rx.Gain = 10; %% Does not matter
            Rx.Address = 'ip:192.168.1.2';
            Rx.SamplingRate = 122.88e6;
%             Rx.SamplingRate = 15.36e6;
            Rx.GainMode = 'slow_attack';
            
            % ADRV9009 Specific parameters
%             Rx.CustomProfileFilename = 'SOM.ftr';
            
            ExtendedTxParams = [];
            ExtendedRxParams = [];
            
            %% Check hardware connected
            testCase.CheckDevice('ip',Rx.Device,Rx.Address(4:end),false);
            
            %% Run Test
            data = testCase.SDRLoopbackLTEEVMTest('LTE10',Frequencies,...
                Tx,Rx,ExtendedTxParams,ExtendedRxParams,testname);
            
            %% Log data
            json = [testname,'_',num2str(int32(now)),'.json'];
            testCase.saveToJSON(json, data);
            
        end
        
        function LTE10_ADRV9009_PXA_NEW(testCase)
            
            import matlab.unittest.plugins.DiagnosticsRecordingPlugin
            
            %% Required test configs
            testname = 'LTE10_ADRV9009_SOM';
            testCase.author = 'ADI';
            Frequencies = (0.4:0.25:5.8).*1e9;
            testCase.LoopIterationsPerFrequency = 4;
            
            Tx = struct;
            Tx.Device = @()adi.ADRV9009.Tx();
            Tx.Gain = -10;
            Tx.Address = 'ip:192.168.1.2';
            Tx.SamplingRate = 122.88e6;
            
            Rx = struct;
            Rx.Device = @()N9030A();
            Rx.Gain = 10;
            Rx.Address = '192.168.1.10';
            Rx.SamplingRate = 15.36e6;
            
            % ADRV9009 Specific parameters
            Tx.CustomProfileFilename = 'SOM.ftr';
            
            ExtendedTxParams = [];
            ExtendedRxParams = [];
            
            %% Check hardware connected
            testCase.CheckDevice('ip',Tx.Device,Tx.Address(4:end),true);
            
            %% Run Test
            data = testCase.SDRLoopbackLTEEVMTest('LTE10',Frequencies,...
                Tx,Rx,ExtendedTxParams,ExtendedRxParams,testname);
            
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
            testCase.uriTX = 'ip:192.168.1.2';
            testCase.uriRX = '192.168.1.10';
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
