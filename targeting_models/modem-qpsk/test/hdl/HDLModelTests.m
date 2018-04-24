classdef (Abstract) HDLModelTests < matlab.unittest.TestCase
    
    properties
        radioRx
        radioTx
        BasebandSampleRate = 20e6;
        
        txFrequencyOffset = 0;
        
        defaultPacketLengthBytes = 200*8;
        
        packetsToCollect = 1e6;
        
        DesignBuilt = false;
        DesignDeployed = false;
        
        savedBitpath = 'hdl_prj/vivado_ip_prj/vivado_prj.runs/impl_1/system_wrapper.bit';
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% HDL
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %% Scaffolding
        function bitpath = buildDesign(testCase,designFunctionName)
            if testCase.DesignBuilt
                bitpath = testCase.savedBitpath;
                return
            end
            % Setup HDL build environment
            setupHDL;
            % Build design from WA generated script
            eval(designFunctionName);
            % Build path for generated code
            bitpath = [hWC.ProjectFolder,'/vivado_ip_prj/vivado_prj.runs/impl_1/system_wrapper.bit'];
            testCase.savedBitpath = bitpath;
            % Check synthesis results
            testCase.assertTrue(checkTimingReport(hWC.ProjectFolder));
            testCase.DesignBuilt = true;
        end
        
        % Push design to hardware
        function deployDesign(testCase,dpath)
            if testCase.DesignDeployed
                return
            end
            % Initialize device
            if ~strcmp(testCase.transmitterDevice,'Pluto')
                dev = sdrdev(testCase.transmitterDevice);
            elseif ~strcmp(testCase.receiverDevice,'Pluto')
                dev = sdrdev(testCase.receiverDevice);
            else
                return;
            end
            testCase.assertTrue(~isempty(dev));
            % Send to device
            downloadImage(dev,'FPGAImage',dpath);
            i = dev.info;
            disp(i);
            %testCase.assertFalse(strcmp(i.HardwareRxCapabilities, 'Device does not have targeted Rx DUT'));
            %testCase.assertFalse(strcmp(i.HardwareTxCapabilities, 'Device does not have targeted Tx DUT'));
            testCase.DesignDeployed = true;
        end
        
        function checkPackets(testCase,results)
            % Match sure we didnt timeout
            testCase.assertFalse(results.timeout,'Timeout occurred');
            % Check ratio of good to bad packets
            testCase.assertLessThanOrEqual(results.errorPackets/results.validPackets,0.001,'Poor BER');
            % Check ratio of good to bad packets
            testCase.assertLessThanOrEqual(results.badPacketsLengths/results.validPackets,0.001,'Too many wrong packets');
        end
        
        % Start Stop transmitter
        function startTransmitterBackground(testCase,txType,StartStop,waveform)
            
            switch txType
                case 'Deployed'
                    if strcmp(StartStop,'Start')
                        disp('Starting TX');
                        % Setup and Start TX
                        load_system('tx');
                        %open_system('tx');
                        set_param('tx/PacketBytes','Value',...
                            ['int16(',num2str(int16(testCase.defaultPacketLengthBytes)),')'])
                        set_param(gcb,...
                            'CenterFrequency',num2str(testCase.CenterFrequency+testCase.txFrequencyOffset));
                        set_param('tx','SimulationCommand','start')
                        while ~strcmp(get_param('tx','SimulationStatus'),'running')
                            pause(0.1);
                        end
                        pause(4);
                    else
                        %% Stop TX
                        disp('Stopping TX');
                        set_param('tx','SimulationCommand','stop')
                        close_system('tx',false);
                    end
                    
                case 'TransmitRepeat'
                    if strcmp(StartStop,'Start')
                        disp('Starting TX');
                        % Setup and Start TX
                        testCase.radioTx = sdrtx(...
                            testCase.transmitterDevice,...
                            'BasebandSampleRate',...
                            testCase.BasebandSampleRate...
                            );
                        if ~strcmp(testCase.transmitterDevice,'Pluto')
                            testCase.radioTx.BypassUserLogic = true;
                        end
                        testCase.radioTx.CenterFrequency = ...
                            testCase.CenterFrequency+...
                            testCase.txFrequencyOffset;
                        testCase.radioTx.transmitRepeat(waveform);
                    else
                        % Stop TX
                        disp('Stopping TX');
                        testCase.radioTx.release();
                    end
            end
            
        end
        
        
        function results = hdlRXOnlyCollect(testCase,packetsToCollect,RXGainConfig)
            % RX
            if isempty(RXGainConfig)
                Gain = testCase.RadioDefaultRXGainConfig.Gain;
                GainMode = testCase.RadioDefaultRXGainConfig.Mode;
            else
                Gain = RXGainConfig.Gain;
                GainMode = RXGainConfig.Mode;
            end
            rx = sdrrx(testCase.receiverDevice,...
                'BasebandSampleRate',testCase.BasebandSampleRate,...
                'CenterFrequency',testCase.CenterFrequency,...
                'OutputDataType','int16',...
                'SamplesPerFrame',2^15,...
                'GainSource', GainMode,'Gain',Gain);
            rx.BypassUserLogic = false;
            validPackets = 0;
            errorPackets = 0;
            badPacketsLengths = 0;
            goodPacketsLengths = 0;
            total = 0;
            timeout = false;
            tic;
            disp('Starting RX');
            errorPos = zeros(packetsToCollect+100,1);
            % Remove first packets
            while total<packetsToCollect
                try
                    [d,~,lost] = rx();
                    if lost>0
                        warning('Lost samples');
                    end
                catch
                    timeout = true;
                    break
                end
                if (toc > 20) && (errorPackets==0) && (validPackets==0)
                    timeout = true;
                    break;
                end
                %% Evaluate interface model results
                r = real(d);
                i = imag(d);
                
                loc = find(r~=1);
                
                a = sum(r(loc)==4); b = sum(r(loc)==2);
                errorPackets = errorPackets + a;
                validPackets = validPackets + b;
                %disp(mean(i(loc)));
                errorPos(total+1:total+a+b) = r(loc);
                total = total + a + b;
                
                badPacketsLengths = badPacketsLengths + sum(i(loc)~=testCase.defaultPacketLengthBytes);
                goodPacketsLengths = goodPacketsLengths + sum(i(loc)==testCase.defaultPacketLengthBytes);
                %fprintf('Valid %d | Failures %d | Bad Lengths %d | Good Lengths %d\n',...
                %    validPackets,errorPackets,badPacketsLengths,goodPacketsLengths);
            end
            disp('Stopping RX');
            clear rx;
            stem(errorPos);xlabel('Packets');ylabel('Status');
            results = struct('timeout',timeout,'errorPackets',errorPackets,...
                'validPackets',validPackets,'badPacketsLengths',badPacketsLengths);
            fprintf('Valid %d | Failures %d | Bad Lengths %d | Good Lengths %d\n',...
                    validPackets,errorPackets,badPacketsLengths,goodPacketsLengths);
            
        end
        
        
        %% Scenarios
        function testPacketFrequencyOffsetHDL(testCase,designFunctionName,frequencies,transmitter,waveform)
            
            % Build design if not already built
            dPath = testCase.buildDesign(designFunctionName);
            % Send to device
            testCase.deployDesign(dPath);
            
            % Run test
            for freq = frequencies
                log(testCase,2,sprintf('Testing HDL RX with frequency offset %d (Normalized)',...
                    freq/testCase.SampleRate));
                % Startup transmitter
                testCase.txFrequencyOffset = freq;
                testCase.startTransmitterBackground(transmitter,'Start',waveform);
                % Start receiver and collect data
                results = testCase.hdlRXOnlyCollect(testCase.packetsToCollect,[]);
                % Stop TX
                testCase.startTransmitterBackground(transmitter,'Stop',waveform);
                % Check results
                testCase.checkPackets(results);
            end
            
        end
        
        %         function testPacketErrorRateHDL(testCase,designFunctionName,packetsToCollect)
        %
        %             % Build design if not already built
        %             testCase.buildDesign(designFunctionName);
        %             % Enable transmitter
        %             RxIQ = generateFrame('Packets',4,'EndsGap',0);
        %             RxIQ = testCase.ScaleInput(RxIQ); % Scale for fixed point
        %             testCase.transmitData(RxIQ);
        %             % Run receiver
        %
        %         end
        
    end
end

