classdef E8267D < matlab.System
    % E8267D Vector Signal Generator
    
    properties
        IP = '10.66.98.158'
        ScaleInput = true;
        OutputPower = -30;
        CenterFrequency = 1e9;
        SampleRate = 10e6;
    end
    
    properties (Access = private)
        dev
    end
    
    methods
        % Constructor
        function obj = E8267D(varargin)
            % Support name-value pair arguments when constructing object
            setProperties(obj,nargin,varargin{:})
            
        end
        
        function sendCommand(obj,cmd)
            fprintf(obj.dev,cmd);
        end
        
        function Setup(obj,TxDataLength)
%             obj.CenterFrequency = CenterFrequency;
            if TxDataLength<60
                error('Tx Data must be at least 60 samples');
            end
            % Connect to instrument
            foundVISA = instrhwinfo('visa');
            obj.dev = visa(foundVISA.InstalledAdaptors{1}, ...
                sprintf('TCPIP0::%s::inst0::INSTR',obj.IP));
            % Set up the output buffer size
            obj.dev.OutputBufferSize = 4*(TxDataLength*2) + 1024;
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
            
            
        end
        
        function Release(obj)
            % Clear connected devices
            g = instrfind;
            fclose(g);
            fclose(obj.dev); 
            delete(obj.dev); 
        end
        
        function EnableRX(~)
            error('This object does not support receive mode');
            
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
            % Write the data to the instrument
            fprintf('Starting Download of %d IQ samples...\n',size(txWaveform,2)/2);
            % filename for the data in the ARB
            ArbFileName = 'MATLABWfm';
            binblockwrite(obj.dev,txWaveform,'uint16',[':MEM:DATA "NVWFM:' ArbFileName '",']);
            fprintf(obj.dev,'');
            % Wait till operation completes
            obj.localWaitTillComplete();
            
            % Display any instrument errors
            obj.localDisplayInstrumentErrors();
            % Display any instrument errors
            obj.localDisplayInstrumentErrors();
            
            
            % Clear volatile memory waveforms
            fprintf(obj.dev, ':MMEMory:DELete:WFM');
            % Copy the waveform to volatile memory
            fprintf(obj.dev,[':MEMory:COPY:NAME "NVWFM:' ArbFileName '","WFM1:NVWFM"']);
            % Wait till operation completes
            obj.localWaitTillComplete();
            % Display any instrument errors
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
            fprintf(obj.dev, ['SOURce:FREQuency ' num2str(obj.CenterFrequency) 'Hz']);
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
        
        function wave = ScaleInputData(~,wave)
            % Scale the waveform as necessary
            tmp = max(abs([max(wave) min(wave)]));
            if (tmp == 0)
                tmp = 1;
            end
            
            % ARB binary range is 2's Compliment -32768 to + 32767
            % So scale the waveform to +/- 32767
            scale = 2^15-1;
            scale = scale/tmp;
            wave = round(wave * scale);
            modval = 2^16;
            % Get data from double to uint16 as required by instrument
            wave = uint16(mod(modval + wave, modval));
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
            while ~contains(lower(instrumentError),'no error')
                fprintf('\tInstrument Error: %s',instrumentError);
                instrumentError = query(obj.dev,'SYSTem:ERRor:NEXT?');
            end
        end
        
    end
    
end

