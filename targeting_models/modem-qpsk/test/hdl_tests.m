classdef (TestTags = {'HDL'}) hdl_tests < ReceiverModelTests & HDLModelTests
    %% Frequency offset tests
    methods (Test, TestTags = {'Environmental','Radio','Fixed'})
        %%
        function testFrequencyOffsetsPlutoTXHDL(testCase)
            designFunctionName = 'hdlworkflow_combinedTxRx';
            testCase.receiverDevice = 'ZC706 and FMCOMMS2/3/4';

            testCase.transmitterDevice = 'Pluto';
            transmitter = 'TransmitRepeat';
            testCase.defaultPacketLengthBytes = 20*8;
            waveform = generateFrame('EndsGap',0,'StartPadding',0,...
                'EndPadding',0,'Packets',4,...
                'PayloadBytes',testCase.defaultPacketLengthBytes*8,...
                'Gap',1e3);
            
            frequencies = [0,1e2,1e3]*20; % Note default fs = 20e6
            testCase.testPacketFrequencyOffsetHDL...
                (designFunctionName,frequencies,transmitter,waveform)
        end
        %%
        function testFrequencyOffsetsLoopbackHDL(testCase)
            testCase.DesignBuilt = true;
            testCase.DesignDeployed = true;
            designFunctionName = 'hdlworkflow_combinedTxRx';
            testCase.receiverDevice = 'ZC706 and FMCOMMS2/3/4';
            
            testCase.transmitterDevice = 'ZC706 and FMCOMMS2/3/4';
            transmitter = 'TransmitRepeat';
            testCase.defaultPacketLengthBytes = 20*8;
            waveform = generateFrame('EndsGap',0,'StartPadding',0,...
                'EndPadding',0,'Packets',4,...
                'PayloadBytes',testCase.defaultPacketLengthBytes*8,...
                'Gap',1e3);
            
            frequencies = [0,1e2,1e3,2e3]*20; % Note default fs = 20e6
            testCase.testPacketFrequencyOffsetHDL...
                (designFunctionName,frequencies,transmitter,waveform)
        end
        %%
        function testFrequencyOffsetsFullDeployHDL(testCase)
            testCase.DesignBuilt = true;
            testCase.DesignDeployed = true;
            designFunctionName = 'hdlworkflow_combinedTxRx';
            testCase.receiverDevice = 'ZC706 and FMCOMMS2/3/4';
            
            testCase.transmitterDevice = 'ZC706 and FMCOMMS2/3/4';
            transmitter = 'Deployed';waveform = [];
            testCase.defaultPacketLengthBytes = 10*8*8;
            
            frequencies = [0,1e2,1e3,2e3]*20; % Note default fs = 20e6
            testCase.testPacketFrequencyOffsetHDL...
                (designFunctionName,frequencies,transmitter,waveform)
        end
    end
    %
end
