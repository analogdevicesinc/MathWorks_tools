classdef DeviceRuntime < DeviceConfig
    
    properties (Abstract)
        RxFrequencyCorrectionFactor
        author
    end
    
    methods
        
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
        
        function dataRX = DeviceCapture(obj,receiver)
            if strcmpi(class(receiver),'N9030A')
                % N9030A
                dataRX = receiver.EnableRX();
            else
                % SDR
                if strcmpi(class(receiver),'pluto') && ...
                   strcmpi(obj.author,'ADI') && ...
                   obj.RxFrequencyCorrectionFactor ~= 0
                   % Specialized call
                   receiver(); 
                   receiver.setDeviceAttributeLongLong('xo_correction',...
                       obj.RxFrequencyCorrectionFactor);
                   obj.RxFrequencyCorrectionFactor = ...
                       receiver.getDeviceAttributeLongLong('xo_correction');
                end
                for k=1:20
                    len = 0;
                    while len == 0
                        [dataRX,len] = receiver();
                    end
                end
            end
        end
        
        function dataRX = DeviceToDevice(obj, ...
                Tx, Rx, ...
                ExtendedTxParams, ExtendedRxParams, ...
                dataTX)
            % Set up devices
            [sdrTransmitter, sdrReceiver] = ConfigureDevices(obj,...
                Tx, Rx, ExtendedTxParams, ExtendedRxParams, dataTX);
            % Capture RX
            obj.log(1,'Starting a new RF capture.');
            dataRX = obj.DeviceCapture(sdrReceiver);
            % Resample
            if Tx.SamplingRate>Rx.SamplingRate
                warning('Tx Sample Rate > Rx Sample Rate, signal may be larger than Rx can recover');
            end
            if Tx.SamplingRate ~= Rx.SamplingRate
                dataRX = resample(double(dataRX),Tx.SamplingRate,...
                    Rx.SamplingRate);
            end
            % Cleanup
            sdrTransmitter.release();
            sdrReceiver.release();
            clear sdrTransmitter sdrReceiver
            dataRX = double(dataRX)./max(abs(double(dataRX)));
        end
    end
end

