classdef N5182B < matlab.System
    % N5182B MXG Vector Signal Generator
    
    properties
%        IP = '10.66.98.187'
        IP = '169.254.189.21';
        ScaleInput = true;
        FixedOutput = true;
        OutputPower = -30;
        SampleRate = 10e6;
        EnableCalibration = true;
        CenterFrequency = 1e9;
        FrequencyBias = 0;
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
        function obj = N5182B(varargin)
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
        
        function Setup(obj,TxDataLength)
            %obj.CenterFrequency = CenterFrequency;
            if TxDataLength<60
                error('Tx Data must be at least 60 samples');
            end
            % Connect to instrument
            foundVISA = instrhwinfo('visa');
            obj.dev = visa(foundVISA.InstalledAdaptors{2}, ...
                sprintf('TCPIP0::%s::inst0::INSTR',obj.IP));
            % Set up the output buffer size
            obj.dev.OutputBufferSize = 4*(TxDataLength*2);%% getz + 1024;
            % Set the timeout
            obj.dev.Timeout = 30;
            % Set object to use BigEndian format
            obj.dev.ByteOrder = 'bigEndian';
            % Open connection to the instrument
            fopen(obj.dev);            
            % Clear hardware buffers on the instrument
            clrdevice(obj.dev);
            % Reset instrument and clear instrument error queue
            fprintf(obj.dev,'*RST;*CLS');
            % Some settings commands to make sure we don't damage the instrument
            fprintf(obj.dev,':SOURce:RADio:ARB:STATe OFF');
            fprintf(obj.dev,':OUTPut:MODulation:STATe OFF');
            fprintf(obj.dev,':OUTPut:STATe OFF');
            obj.DeviceSetup = true;
            %obj.CalibrateBand();
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
        
        function EnableTX(obj,txWaveform)
            % Check size
            IQsize = size(txWaveform);
            % User gave input as column vector. Reshape it to row vector.
            if ~isequal(IQsize(1),1)
                % warning('Wrong input detected. Automatically converting to row vector.');
                txWaveform = reshape(txWaveform,1,IQsize(1));
            end
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
                obj.Release();
                obj.Setup(length(txWaveform));
            end
            
            % Reset instrument and clear instrument error queue
            fprintf(obj.dev,'*RST;*CLS');
            % Some settings commands to make sure we don't damage the instrument
            fprintf(obj.dev,':SOURce:RADio:ARB:STATe OFF');
            fprintf(obj.dev,':OUTPut:MODulation:STATe OFF');
            fprintf(obj.dev,':OUTPut:STATe OFF');
            % Write the data to the instrument
            fprintf('Starting Download of %d IQ samples...\n',size(txWaveform,2)/2);
            % get 10 random char, so we have unique filename
            SET = char(['a':'z' '0':'9']) ;
            NSET = length(SET) ;
            N = 10 ; % pick N numbers
            i = ceil(NSET*rand(1,N)) ; % with repeat
            R = SET(i) ;
            % filename for the data in the ARB
            ArbFileName = ['MATLAB_', num2str(length(txWaveform)), '_', R];
            binblockwrite(obj.dev,txWaveform,'uint16',[':MEM:DATA "NVWFM:' ArbFileName '",']);
            fprintf(obj.dev,'');
            % Wait till operation completes
            obj.localWaitTillComplete();
            % Clear volatile memory waveforms
            fprintf(obj.dev, ':MMEMory:DELete:WFM');
            % Copy the waveform to volatile memory
            fprintf(obj.dev,[':MEMory:COPY:NAME "NVWFM:' ArbFileName '","WFM1:NVWFM"']);
            % Wait till operation completes
            obj.localWaitTillComplete();
            % Display any instrument errors
            pause(1);
            obj.localDisplayInstrumentErrors();
            fprintf(obj.dev,[':MEMory:DELete:NAME "NVWFM:' ArbFileName '"']);
            % Wait till operation completes
            obj.localWaitTillComplete();
            % Display any instrument errors
            pause(1);
            obj.localDisplayInstrumentErrors();
            %fprintf('\t...done!\n');
            
            % Set up markers if we need to use this for synchronization using the
            % Event1 hardware output on the signal generator
            
            % Clear all markers from the file
            fprintf(obj.dev,':SOURce:RADio:ARB:MARKer:CLEar:ALL "NVWFM",1');
            % Set marker 1 (first input after filename), starting at the first point
            % (second input), ending at point 1 (third input) and skipping 0.
            % Refer page 295 of
            % <http://cp.literature.agilent.com/litweb/pdf/N5180-90004.pdf Programmer's manual>
            % for more info
            fprintf(obj.dev,':SOURce:RADio:ARB:MARKer:SET "NVWFM",1,1,1,0');
            % Play back the selected waveform
            fprintf(obj.dev, ':SOURce:RADio:ARB:WAVeform "WFM1:NVWFM"');
            fprintf(obj.dev,[':SOURce:RADio:ARB:SCLock:RATE ' num2str(obj.SampleRate) 'Hz']);
            % set center frequency (Hz)
            fprintf(obj.dev, ['SOURce:FREQuency ' num2str(round(obj.CenterFrequency+obj.FrequencyBias)) 'Hz']);
            % set output power (dBm)
            fprintf(obj.dev, ['POWer ' num2str(obj.OutputPower)]);
            % set runtime scaling to 75% of DAC range so that interpolation by the
            % instrument baseband generator doesn't cause errors
            % Refer page 159 of
            % <http://cp.literature.agilent.com/litweb/pdf/E4400-90503.pdf User guide>
            % for more info
            fprintf(obj.dev, 'RADio:ARB:RSCaling 75');
            % Turn on output protection
            fprintf(obj.dev,':OUTPut:PROTection ON');
            % ARB Radio on
            fprintf(obj.dev, ':SOURce:RADio:ARB:STATe ON');
            % modulator on
            fprintf(obj.dev, ':OUTPut:MODulation:STATe ON');
            % RF output on
            fprintf(obj.dev, ':OUTPut:STATe ON');
            % Display any instrument errors
            obj.localDisplayInstrumentErrors();
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
        end
        
        function str = name(obj)
           if obj.FixedOutput
               str = ['Keysight ' class(obj) ' (' num2str(obj.OutputPower) 'dBm)'];
           else
               str = ['Keysight ' class(obj) ];
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

