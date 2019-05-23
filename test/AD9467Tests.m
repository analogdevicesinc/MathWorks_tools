classdef AD9467Tests < HardwareTests
    
    properties
        uri = 'ip:192.168.3.2';
        author = 'ADI';
    end
    
    methods(TestClassSetup)
        % Check hardware connected
        function CheckForHardware(testCase)
            Device = @()adi.AD9467.Rx;
            testCase.CheckDevice('ip',Device,testCase.uri(4:end),false);
        end
    end
    
    methods (Test)
        
        function testAD9467Rx(testCase)
            % Test Rx DMA data output
            rx = adi.AD9467.Rx('uri',testCase.uri);
            [out, valid] = rx();
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end
        
    end
    
end

