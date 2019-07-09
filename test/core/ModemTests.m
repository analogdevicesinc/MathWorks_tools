classdef ModemTests < matlab.unittest.TestCase
    
    properties
        demopath = ''
    end
    
    methods(TestClassSetup)
        function Setup(testCase)
            addpath(genpath('targeting_models'));
            setupHDL;
            cd ..
            testCase.demopath = pwd;
        end
    end
    
    methods (Static)
    end
    
    methods (Test)
        
        function Build_External_Mode(testCase)
            folder = [testCase.demopath,'/targeting_models/modem-qpsk/FixedPoint/demos'];
            cd(folder);
            folder = 'External_Mode';
            cd(folder);
            hdlworkflow
        end
        
        function Build_Standard_IQ(testCase)
            folder = [testCase.demopath,'/targeting_models/modem-qpsk/FixedPoint/demos'];
            cd(folder);
            folder = 'Standard_IQ';
            cd(folder);
            hdlworkflow
        end
        
        function Build_FPGA_Capture(testCase)
            folder = [testCase.demopath,'/targeting_models/modem-qpsk/FixedPoint/demos'];
            cd(folder);
            folder = 'FPGA_Capture';
            cd(folder);
            generateBadFrame('StartPadding',2^4);
            hdlworkflow
        end
        
    end
    
end

