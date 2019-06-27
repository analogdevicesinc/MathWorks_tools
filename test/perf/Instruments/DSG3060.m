classdef DSG3060 < matlab.System
    % DSG3060 Rigol Signal Generator
    
    properties
%        IP = '10.66.98.187'
        USB = 'USB0::0x1AB1::0x0992::DSG3A172400066::INSTR';
        ScaleInput = true;
        FixedOutput = true;
        Attenuation = 0;
        OutputPower = -30;
        SampleRate = 10e6;
        EnableCalibration = true;
        CenterFrequency = 1e9;
        FrequencyBias = 0;
        filename = 'ADI_IQ_DATA2'
    end
    
    properties (Access = private)
        dev
        DeviceSetup = false;
    end
    
    methods (Access = protected)
        function releaseImpl(obj)
            Release(obj);
        end
    end
    
    methods
        % Constructor
        function obj = DSG3060(varargin)
            % Support name-value pair arguments when constructing object
            setProperties(obj,nargin,varargin{:})
        end
        
        % Check CenterFrequency for calibration case
        function set.CenterFrequency(obj, value)
            org = obj.CenterFrequency;
            obj.CenterFrequency = value;
            if abs(value - org) > (obj.SampleRate)/2 && obj.DeviceSetup%#ok<MCSUP>
                obj.CalibrateBand();
            end
        end
        function sendCommand(obj,cmd)
            fprintf(obj.dev,cmd);
        end
        
        function Setup(obj,~)
            %obj.CenterFrequency = CenterFrequency;
%             if TxDataLength<60
%                 error('Tx Data must be at least 60 samples');
%             end
            % Connect to instrument
%             foundVISA = instrhwinfo('ivi');
%             obj.dev = visa(foundVISA.InstalledAdaptors{2}, ...
%                 sprintf('TCPIP0::%s::inst0::INSTR',obj.IP));
            obj.dev = visa('ni',obj.USB);
            % Set the timeout
            obj.dev.Timeout = 30;
            % Open connection to the instrument
            fopen(obj.dev);            
            % Reset instrument and clear instrument error queue
            fprintf(obj.dev,'*RST;*CLS');
            % Some settings commands to make sure we don't damage the instrument
            fprintf(obj.dev,':SOURce:IQ:BASeout:STATe OFF');
            fprintf(obj.dev,':OUTPut:STATe OFF');
            fprintf(obj.dev,[':SOURce:IQ:SAMPle ', obj.SampleRate]);
            obj.DeviceSetup = true;
        end
        
        function Release(obj)
            % Clear connected devices
            g = instrfind;
            if ~isempty(g)
            fclose(g);
            fclose(obj.dev); 
            delete(obj.dev);
            end
            obj.DeviceSetup = false;
        end
        
        function EnableRX(~)
            error('This object does not support receive mode');
            
        end
        
        function transmitRepeat(obj,txWaveform)
            EnableTX(obj,txWaveform);
        end
        
        function CreateWaveformFile(obj,txWaveform)
            % Check size
            IQsize = size(txWaveform);
            % User gave input as column vector. Reshape it to row vector.
            if ~isequal(IQsize(1),1)
                % warning('Wrong input detected. Automatically converting to row vector.');
                txWaveform = reshape(txWaveform,1,IQsize(1));
            end
            obj.ScaleInputData2(txWaveform);
            % Separate out the real and imaginary data in the IQ Waveform
            txWaveform = [real(txWaveform);imag(txWaveform)];
            txWaveform = txWaveform(:)'; % transpose the waveform
            % Scale to uint16
            if obj.ScaleInput
                txWaveform = obj.ScaleInputData(txWaveform);
            end
            minSigSize = 1e6;
            if length(txWaveform)<minSigSize
                copies = floor(minSigSize/length(txWaveform)) + 1;
                txWaveform = repmat(txWaveform,1,copies);
            end
            fprintf('Outputing waveform to file: %s.csv\n',[pwd,'\',obj.filename]);
            obj.WriteToFile(txWaveform);
            fprintf('Removing old file from instrument with name: %s.arb\n',obj.filename);
            fprintf(obj.dev,sprintf(':MMEMory:DELete %s.arb',obj.filename));
        end
        
        function EnableTX(obj,~)

            
            % Reset instrument and clear instrument error queue
            fprintf(obj.dev,'*RST;*CLS');
            fprintf(obj.dev,':SYST:PRES:TYPE FAC');
            fprintf(obj.dev,':SYST:PRES');
            % Some settings commands to make sure we don't damage the instrument
%             fprintf(obj.dev,':SOURce:IQ:BASeout:STATe OFF');
%             fprintf(obj.dev,':OUTPut:STATe OFF');
            fprintf(obj.dev,':SOURce:IQ:BASeout:STATe OFF');
            fprintf(obj.dev,':SOURce:IQ:MODe:STATe OFF');
            fprintf(obj.dev, ':SOURce:MODulation:STATe OFF');
            fprintf(obj.dev, ':OUTPut:STATe OFF');
            
            % set center frequency (Hz)
            fprintf(obj.dev, ['SOURce:FREQuency ' num2str(round(obj.CenterFrequency+obj.FrequencyBias)) 'Hz']);
            % set output attenutation (dB)
            fprintf(obj.dev, ['SOURce:LEVel:ATTenuation ', num2str(obj.Attenuation)]);
            
            % Set file source
            fprintf(obj.dev,sprintf(':MMEMory:LOAD %s.arb',obj.filename));
            
            % Enable output
            fprintf(obj.dev,':SOURce:IQ:MODe INTernal');
            fprintf(obj.dev,[':SOURce:LEVel ',num2str(obj.OutputPower)]);
            
            fprintf(obj.dev,':SOURce:IQ:BASeout:STATe ON');
            fprintf(obj.dev,':SOURce:IQ:MODe:STATe ON');
            fprintf(obj.dev,':SOURce:MODulation:STATe ON');
            fprintf(obj.dev,':OUTPut:STATe ON');
            
            % Display any instrument errors
%             obj.localDisplayInstrumentErrors();
        end
        
        function WriteToFile(obj,data)
            fileID = fopen([obj.filename,'.csv'],'w');
            for k = 1:length(data)-1
                fprintf(fileID,'%d,',data(k));
            end
            fprintf(fileID,'%d',data(end));
            fclose(fileID);
        end
        
        function CalibrateBand(obj)
           
            % Setup frequency band for calibration
            %obj.sendCommand([':CALibration:IQ:STARt ' num2str(round(obj.CenterFrequency-obj.SampleRate)) ' Hz']);
            %obj.sendCommand([':CALibration:IQ:STOP ' num2str(round(obj.CenterFrequency+obj.SampleRate)) ' Hz']);
            % Do calibration
            %obj.sendCommand(':CALibration:IQ:USER');
            localWaitTillComplete(obj);
            obj.localDisplayInstrumentErrors();
        end
        
        function wave = ScaleInputData2(~,wave)
            %   (1) normalize all I/Q data to a peak vector length of 1.0
            Idata = real(wave);
            Qdata = imag(wave);
            maxIQData = max(abs(Idata + 1j*Qdata));
            Idata = Idata / maxIQData;
            Qdata = Qdata / maxIQData;
            
            
            SeqLength = length(Idata);
            IqData = single( zeros(1, 2*SeqLength) );
            IqData(1:2:end) = single(Idata);
            IqData(2:2:end) = single(Qdata);
            
            %   (2) convert data for 14 bit DAC
            iqDataRound = floor( IqData * 0.81 * (2^13-1) + 0.5);
            
            
            %   (3) write data into binary file,signed int16
            datFileName = 'data.dat';
            fid = fopen(datFileName, 'w');
            fwrite(fid,iqDataRound,'int16');
            fclose(fid);
        end
        
        function wave = ScaleInputData(~,wave)
            % Scale the waveform as necessary
            tmp = max(abs([max(wave) min(wave)]));
            if (tmp == 0)
                tmp = 1;
            end
            
            % ARB binary range is 2's Compliment -32768 to + 32767
            % So scale the waveform to +/- 32767
            targetBits = 16;
            %scale = 2^15-1;
            scale = 2^(targetBits-1)-1;
            scale = scale/tmp;
            wave = round(wave * scale);
            %modval = 2^16;
            modval = 2^targetBits;
            % Get data from double to uint16 as required by instrument
            wave = uint16(mod(modval + wave, modval));
%             wave = int16(wave);
            
        end
        
        function str = name(obj)
           if obj.FixedOutput
               str = ['Rigol ' class(obj) ' (' num2str(obj.OutputPower) 'dBm)'];
           else
               str = ['Rigol ' class(obj) ];
           end
        end
        
        function localWaitTillComplete(obj)
            % Wait until instrument operation is complete
            operationComplete = str2double(query(obj.dev,'*OPC?'));
            while ~operationComplete
                operationComplete = str2double(query(obj.dev,'*OPC?'));
            end
        end
        
        function localDisplayInstrumentErrors(obj)
            % Display any instrument errors
            instrumentError = query(obj.dev,'SYSTem:ERRor?');
            errors = 0; maxErrors = 10;
            while ~contains(lower(instrumentError),'no error') && (errors<maxErrors)
                fprintf('\tInstrument Error: %s',instrumentError);
                instrumentError = query(obj.dev,'SYSTem:ERRor:NEXT?');
                errors = errors + 1;
            end
        end
        
    end
    
    methods (Static)
        function handlePropEvents(~,evnt)
            evnt.AffectedObject.CalibrateBand();
            %sprintf('PropOne is %s\n',num2str(evnt.AffectedObject.CalibrateBand))
        end
    end
    
end

