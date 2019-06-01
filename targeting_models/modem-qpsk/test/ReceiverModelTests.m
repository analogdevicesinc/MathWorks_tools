classdef (Abstract) ReceiverModelTests < matlab.unittest.TestCase
    % Test QPSK receiver model
    %
    % Example call:
    %  test = ReceiverModelTests;
    %  test.run()
    
    properties
        radioObject = [];
        SampleRate = 20e6;
        CenterFrequency = 900e6;
        FPMATLABReceiverFunctionName = 'ReceiverFloatingPoint';
        XPSimulinkReceiverModelName = 'Receiver_UnderTest_Fixed';
        FPSimulinkReceiverModelName = 'Receiver_UnderTest_Float';
        FramesToReceive = 4;
        ScopesToDisable = {'Constellation','Scope','Spectrum'};
        EnableVisuals = false;
        HardwareCheck = false;
        SimChannelSNR = 20;
        
        transmitterDevice = 'ZC706 and FMCOMMS2/3/4';
        %transmitterDevice = 'Pluto';
        receiverDevice = 'ZC706 and FMCOMMS2/3/4';
        %receiverDevice = 'Pluto';
        
        % Pluto only
        transmitterRadioID = 'usb:1';
        receiverRadioID = 'usb:0';
        
    end
    
    properties (Constant)
        RadioDefaultRXGainConfig=struct('Gain',50,'Mode','AGC Slow Attack');
        RadioDefaultTXGain = -20;%-30;
    end
    
    properties (Access = private)
        warningState
        Radio
    end
    
    methods(TestClassSetup)
        % Load example settings from mat file
        function DisableWarnings(testCase)
            disp('Loading');
            testCase.warningState = warning;
            warning('off','all');
        end
        
        function findRadio(testCase)
            try
                d1 = sdrdev('Pluto'); setupSession(d1);
                %r = findPlutoRadio;% (Remove untested)
		r = sdrrx('Pluto');r();
            catch
                r = [];
            end
            if isempty(r) && testCase.HardwareCheck
                error('No radio attached');
            end
            testCase.Radio = r;
        end
    end
    
    methods(TestClassTeardown)
        function EnableOriginalWarnings(testCase)
            disp('Cleanup');
            warning(testCase.warningState);
        end
    end
    
    methods (Static)
        
        % Scale double data for fixed-point model
        function input = ScaleInput(input)
            input = int16((2^10-1).*input);
        end
        % Disable scopes
        function DisableScopes(modelname,blocktypes)
            for block = blocktypes
                scopes = find_system(modelname,'CaseSensitive','off',...
                    'regexp','on','LookUnderMasks','all',...
                    'blocktype',block{:});
                delete_block(scopes);
            end
        end
        
    end
    
    methods % Non-Static Test Scaffolding
        
        % Check receiver struct results
        function checkResults(testCase,results)
            % Check results
            testCase.assertGreaterThanOrEqual(results.packetsFound,....
                testCase.FramesToReceive);
            m = min(results.packetsFound,length(results.crcChecks));
            testCase.assertTrue(sum(...
                results.crcChecks(1:m)==0) >= ...
                testCase.FramesToReceive,'CRC Failed in packet');
%             for i = 1:testCase.FramesToReceive%results.packetsFound
%                 testCase.assertEqual(results.crcChecks(i),0,'CRC Failed in packet');
%             end
%             testCase.assert(sum(results.crcChecks==0),
        end
        % Test MATLAB based receiver
        function testPacketRecoveryMATLAB(testCase,RxIQ,functionName)
            % Run receiver
            rh = str2func(functionName);
            results = rh(testCase,RxIQ);
            % Check results
            testCase.checkResults(results)
        end
        % Test Simulink based receiver
        function testPacketRecoverySimulink(testCase,RxIQ,modelname)
            % Save data to file for model
            bb = comm.BasebandFileWriter('Filename','example.bb',...
                'CenterFrequency',testCase.CenterFrequency,...
                'SampleRate',1e6);%testCase.SampleRate);
            % Cast to fixed if necessary and save data
            bb(RxIQ);
            bb.release();
            pause(2);
            % Set model parameters
            load_system(modelname);
            %open(modelname);
            % Disable linked libraries so we can remove scopes
            %set_param(gcb,'LinkStatus','none')
            if contains(lower(modelname),'fixed')
                set_param([modelname,'/Receiver HDL'],'LinkStatus','none')
            else
                set_param([modelname,'/Receiver'],'LinkStatus','none')
            end
            if ~testCase.EnableVisuals
                testCase.DisableScopes(modelname,testCase.ScopesToDisable);
            end
            %CloseAllScopes(modelname);
            set_param([modelname,'/Baseband File Reader'],...
                'InheritSampleTimeFromFile',1);
            set_param([modelname,'/Baseband File Reader'],...
                'Filename','example.bb');
            set_param([modelname,'/Baseband File Reader'],...
                'SamplesPerFrame',num2str(length(RxIQ)));
            stopTime = length(RxIQ)*1.1/1e6;%testCase.SampleRate;
            set_param(modelname,'StopTime',num2str(stopTime))
            % Run receiver
            sim(modelname);
            % Close simulink
            close_system(modelname, false);
            bdclose('all');
            % Pack results
            results = struct('packetsFound',packetsFound.Data(end),...
                'crcChecks',crcChecks.Data(:,:,end),'failures',failures.Data(:,:,end));
            % Check results
            testCase.checkResults(results);
        end
        % Call receiver
        function runSpecificReceiver(testCase,RxIQ_many_offset,sink)
            % Run and check receiver
            switch sink
                case 'FloatingPointSimulink'
                    testCase.testPacketRecoverySimulink(...
                        RxIQ_many_offset,...
                        testCase.FPSimulinkReceiverModelName);
                case 'FixedPointSimulink'
                    testCase.testPacketRecoverySimulink(...
                        RxIQ_many_offset,...
                        testCase.XPSimulinkReceiverModelName);
                case 'FloatingPointMATLAB'
                    testCase.testPacketRecoveryMATLAB(...
                        RxIQ_many_offset,...
                        testCase.FPMATLABReceiverFunctionName);
                otherwise
                    error(['Unknown case ',sink]);
            end
        end
        % Loop through receiver
        function RxIQ_many_offset = passThroughRadio(testCase,RxIQ,isfixed,RXGainConfig,TXGain,freqOffset)
            if isfixed
                odt = 'int16';
            else
                odt = 'double';
            end
            % TX
            if isempty(TXGain)
                Gain = testCase.RadioDefaultTXGain;
            else
                Gain = TXGain;
            end
            %tx = sdrtx('ZC706 and FMCOMMS2/3/4',... %'Pluto',...
            tx = sdrtx(testCase.transmitterDevice,... %'Pluto',...
                'BasebandSampleRate',testCase.SampleRate,...
                'CenterFrequency',testCase.CenterFrequency+freqOffset,...
                'Gain',Gain);
            if ~strcmp(tx.DeviceName,'Pluto')
                tx.BypassUserLogic = true;
            else
                tx.RadioID = testCase.transmitterRadioID;
            end
            % RX
            if isempty(RXGainConfig)
                Gain = testCase.RadioDefaultRXGainConfig.Gain;
                GainMode = testCase.RadioDefaultRXGainConfig.Mode;
            else
                Gain = RXGainConfig.Gain;
                GainMode = RXGainConfig.Mode;
            end
            rx = sdrrx(testCase.receiverDevice,...
                'BasebandSampleRate',testCase.SampleRate,...
                'CenterFrequency',testCase.CenterFrequency,...
                'OutputDataType',odt,...
                'SamplesPerFrame',ceil(length(RxIQ)*(testCase.FramesToReceive+2)/testCase.FramesToReceive),...
                'GainSource', GainMode,'Gain',Gain);
            if ~strcmp(rx.DeviceName,'Pluto')
                rx.BypassUserLogic = true;
            else
                rx.RadioID = testCase.receiverRadioID;
            end
            tx.transmitRepeat(RxIQ);
            pause(1); % Let transmitter startup
            rx();rx();rx(); % Let AGC settle
            [RxIQ_many_offset,l,o] = rx();
            %RxIQ_many_offset = double(RxIQ_many_offset)./(2^15);
            %RxIQ_many_offset = double(RxIQ_many_offset)./(max(abs(RxIQ_many_offset)));
            if l==0
                error('Zero samples returned from radio');
            elseif o
                warning('Samples lost at receiver');
            end
            clear tx rx;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Test Case Structures
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Test receiver with different packet gaps
        function testPacketGaps(testCase, source, sink, gaps)
            % Generate source data
            for gap = gaps
                % Generate data within interpacket gaps
                RxIQ = generateFrame('Gap',gap,'Packets',testCase.FramesToReceive);
                % Apply to source
                isfixed = contains(lower(sink),'fixed');
                % Apply to source
                if strcmp(source,'radio')
                    error('Not yet implemented');
                elseif strcmp(source,'simulation')
                    if isfixed
                        RxIQ = awgn(RxIQ,testCase.SimChannelSNR,'measured');
                        RxIQ = testCase.ScaleInput(RxIQ);
                    else
                        %RxIQ_many = repmat(RxIQ,testCase.FramesToReceive,1);
                        RxIQ = awgn(0.7.*RxIQ,testCase.SimChannelSNR,'measured');
                        %RxIQ = awgn(RxIQ,testCase.SimChannelSNR,'measured');
                    end
                end
                % Run and check receiver
                log(testCase,2,sprintf('Testing %s with interpacket gap %d',sink,gap));
                testCase.runSpecificReceiver(RxIQ,sink);
            end
        end
        %% Test receiver with different sample rates
        function testSampleRates(testCase, source, sink, rates)
            % Generate source data
            for rate = rates
                % Generate data within interpacket gaps
                %RxIQ = generateFrame();
                RxIQ = generateFrame('Packets',testCase.FramesToReceive);
                % Apply to source
                if strcmp(source,'radio')
                    error('Not yet implemented');
                elseif strcmp(source,'simulation')
                    % Nothing here
                end
                % Run and check receiver
                log(testCase,2,sprintf('Testing %s at sample rate %d',sink,gap));
                testCase.runSpecificReceiver(RxIQ,sink);
            end
        end
        %% Test receiver with different frequency offsets
        function testPacketFrequencyOffset(testCase, source, sink, offsets, GainRXConfig, GainTX)
            pfo = comm.PhaseFrequencyOffset(...
                'SampleRate',testCase.SampleRate);
            if nargin<5
                GainRXConfig = []; GainTX = [];
            elseif nargin<6
                GainTX = [];
            end
            for offset = offsets
                if strcmp(source,'radio')
                    % Generate data
                    RxIQ = generateFrame('Packets',testCase.FramesToReceive,'EndsGap',0);
                    % Apply to source
                    isfixed = contains(lower(sink),'fixed');
                    RxIQ_many_offset = testCase.passThroughRadio(RxIQ,isfixed,GainRXConfig,GainTX,offset);
                elseif strcmp(source,'simulation')
                    % Generate data
                    isfixed = contains(lower(sink),'fixed');
                    if isfixed
                        RxIQ = generateFrame('Packets',testCase.FramesToReceive);                    % Apply to source
                        pfo.release();
                        pfo.FrequencyOffset = offset;
                        RxIQ_many_offset = pfo(RxIQ);
                        RxIQ_many_offset = awgn(RxIQ_many_offset,testCase.SimChannelSNR,'measured');
                        RxIQ_many_offset = testCase.ScaleInput(RxIQ_many_offset);
                    else
                        RxIQ = 0.7.*generateFrame('Packets',testCase.FramesToReceive+1);                    % Apply to source
                        pfo.release();
                        pfo.FrequencyOffset = offset;
                        RxIQ_many_offset = pfo(RxIQ);
                        RxIQ_many_offset = awgn(RxIQ_many_offset,testCase.SimChannelSNR,'measured');
                    end
                end
                % Run and check receiver
                log(testCase,2,sprintf('Testing %s with frequency offset %d (Normalized)',sink,offset/testCase.SampleRate));
                testCase.runSpecificReceiver(RxIQ_many_offset,sink);
            end
        end
        %% Test receiver with different gains (simulates distance and exercises AGC)
        function testPacketGainDifference(testCase, source, sink, RXGainConfig, TXGains)
            % Generate source data
            for TXGain = TXGains
                % Generate data
                % Apply to source
                isfixed = contains(lower(sink),'fixed');
                if strcmp(source,'radio')
                    RxIQ = generateFrame('Packets',testCase.FramesToReceive,'EndsGap',0);
                    RxIQ_many_offset = testCase.passThroughRadio(RxIQ,isfixed, RXGainConfig, TXGain,0);
                elseif strcmp(source,'simulation')
                    RxIQ = generateFrame('Packets',testCase.FramesToReceive);
                    RxIQ_many_gains = RxIQ.*RXGainConfig.Gain.*TXGain;
                    if isfixed
                        RxIQ_many_offset = testCase.ScaleInput(RxIQ_many_gains);
                    end
                end
                % Run and check receiver
                log(testCase,2,sprintf('Testing %s with TX Gain %d',sink,TXGain));
                testCase.runSpecificReceiver(RxIQ_many_offset,sink);
            end
        end
        %% Test receiver with different gains (simulates distance and exercises AGC)
        function testPacketMultipleSizes(testCase, source, sink, sizes)
            % Generate source data
            RxIQ = [];
            for i = 1:length(sizes)
                % Generate data
                if i==1
                    RxIQ = [RxIQ; generateFrame('PayloadBytes',sizes(i),'StartPadding',1e3,'EndPadding',0)]; %#ok<AGROW>
                elseif i==length(sizes)
                    RxIQ = [RxIQ; generateFrame('PayloadBytes',sizes(i),'StartPadding',0,'EndPadding',1e2)]; %#ok<AGROW>
                else
                    RxIQ = [RxIQ; generateFrame('PayloadBytes',sizes(i),'StartPadding',0,'EndPadding',0)]; %#ok<AGROW>
                end
            end
            % Generate data
            isfixed = contains(lower(sink),'fixed');
            if strcmp(source,'radio')
                error('Test should not be run with hardware');
                %RxIQ = testCase.passThroughRadio(RxIQ,isfixed, RXGainConfig, TXGain);
            elseif strcmp(source,'simulation')
                if isfixed
                    RxIQ = awgn(RxIQ,testCase.SimChannelSNR,'measured');                % Apply to source
                    RxIQ = testCase.ScaleInput(RxIQ);
                else
                    RxIQ = awgn(0.7*RxIQ,testCase.SimChannelSNR,'measured');
                end
            end
            % Run and check receiver
            log(testCase,2,sprintf('Testing %s with %d different packet sizes together',sink,int32(length(sizes))));
            testCase.runSpecificReceiver(RxIQ,sink);
        end

            
        
        
    end
    methods (Test)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Tests
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % See subclasses matlab_tests and simulink_tests
        
    end
    
end
