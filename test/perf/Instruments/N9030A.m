
classdef N9030A < matlab.System
    % N9030A Vector Signal Analyzer
    
    % Notes
    % Error: There is not enough memory to create the input buffer
    % Solution: Larger buffer sizes can be specified after increasing the
    %   available heap space for the JVM from 
    %   MATLAB Preferences > General > Java Heap Memory.
    
    properties
        CenterFrequency = 2.4e9; % Hz
        IP = '10.66.100.143';
        MeasureTimeSeconds = 0.1;
        InputBufferSize = 10e6;
        SampleRate = 10e6;
        EnableSpectrumViewAfterMeasurement = true;
        Timeout = 30; % Seconds
        PossibleAttenuations = [0 10 20 30 40];
        Attenuation = 0;
        FrequencyBias = 0;
    end
    
    properties (Access = private)
        dev
        rxWaveform
        spectrumPlotRx
    end
    
    methods (Access = protected)
        function releaseImpl(obj)
            Release(obj);
        end
    end
    
    methods
         % Constructor
        function obj = N9030A(varargin)
            % Support name-value pair arguments when constructing object
            setProperties(obj,nargin,varargin{:})    
        end
        
        function Setup(obj,RxDataLength)
            %obj.InputBufferSize = RxDataLength;
            obj.MeasureTimeSeconds = RxDataLength/obj.SampleRate;
            %obj.CenterFrequency = CenterFrequency;
            % Set up actual instrument
            obj.initPXA();
        end
        
        function Release(obj)
           obj.clearConnectedDevices(); 
        end
        
        function [RxIQ, errors]= EnableRX(obj)
            
            clrdevice(obj.dev);% Clear hardware buffers on the instrument.
            sendCommand(obj,'*RST;*CLS');% Reset instrument and clear instrument error queue
            obj.localWaitTillComplete();% Wait till operation is complete.
            
            errors = obj.setupIQMode(); % Force into IQ Mode
            obj.useInternalTrigger(); % Start collecting data
            [RxIQ,captureSampleRate] = obj.getIQData(); % Pull buffer
            % Process data appropriately
            RxIQ = RxIQ(1:end-1);
            captureSampleRate = round(captureSampleRate);
            RxIQ = resample(RxIQ,obj.SampleRate ,round(captureSampleRate));
            % Set scope to spectrum mode to visualize signal better
            if obj.EnableSpectrumViewAfterMeasurement
                obj.enableSpectrumMode();
            end
        end
        
        function EnableTX(~)
            error('This object does not support transmission mode');
        end
            
        function errors = initPXA(obj)
            % Check for ICT presence
            if isempty(ver('instrument'))
                error(['Please install Instrument Control Toolbox for ',...
                    'this function to work.']);
            end
            % Verify VISA installation and select VISA if available
            foundVISA = instrhwinfo('visa','agilent');
            if ~isempty(foundVISA.AdaptorName)
                obj.dev = visa('agilent', ...
                    sprintf('TCPIP0::%s::inst0::INSTR',obj.IP));
                %usingVISA = true;
            else
                % Untested
                obj.dev = tcpip(obj.Address,5025);
                %usingVISA = false;
            end
            % Set input buffer size
            set(obj.dev,'InputBufferSize', obj.InputBufferSize);
            set(obj.dev,'Timeout',obj.Timeout);% Set timeout to 30 seconds
            set(obj.dev,'ByteOrder','bigEndian');% Set object to use BigEndian format
            fopen(obj.dev);    % Open connection to the instrument
            clrdevice(obj.dev);% Clear hardware buffers on the instrument.
            sendCommand(obj,'*RST;*CLS');% Reset instrument and clear instrument error queue
            obj.localWaitTillComplete();% Wait till operation is complete.
            
            errors = obj.localDisplayInstrumentErrors();
        end
        
        function [IQData,sampleRate] = getIQData(obj)
            % Trigger the instrument and initiate measurement
            sendCommand(obj,'*TRG');
            sendCommand(obj,':INITiate:WAVeform');
            % Wait till operation is complete
            obj.localWaitTillComplete();
            % Read the IQ data
            sendCommand(obj,':READ:WAV0?');
            data=binblockread(obj.dev,'float');
            % Read the additional terminator character from the instrument
            fread(obj.dev,1);
            % Retrieve information about the most recently acquired data
            sendCommand(obj,':FETCH:WAV1?');
            signalSpec = binblockread(obj.dev,'float'); fread(obj.dev,1);
            sampleRate = 1/signalSpec(1);
            % Separate the data and build the complex IQ vector.
            inphase=data(1:2:end);
            quadrature=data(2:2:end);
            IQData=inphase+1i*quadrature;
            % Save to hist
            %obj.rxWaveform = IQData;
        end
        
        function useInternalTrigger(obj)
            % Set the trigger to immediate
            sendCommand(obj,':TRIGger:WAVeform:SOURce IMMediate');
        end
        
        function useExternalTrigger(obj)
            % Set the trigger to external source 1 with positive slope triggering
            % When using external triggering, one needs a low-to-high transition on
            % the physical cable connected to the trigger1 in of the analyzer.
            sendCommand(obj,':TRIGger:WAVeform:SOURce EXTernal1');
            sendCommand(obj,':TRIGger:EXTERNAL1:SLOPe POSitive');
        end
        
        function errors = setupIQMode(obj)
            % Set up signal analyzer mode to Basic/IQ mode
            sendCommand(obj,':INSTrument:SELect BASIC');
            % Set the center frequency
            sendCommand(obj,[':SENSe:FREQuency:CENTer ' num2str(obj.CenterFrequency+obj.FrequencyBias) 'Hz']);
            % Set the resolution bandwidth
            sendCommand(obj,[':SENSe:WAVEform:BANDwidth:RESolution ' num2str(obj.SampleRate) 'Hz']);
            % Set the time for which measurement needs to be made
            sendCommand(obj,[':WAVeform:SWE:TIME '  num2str(obj.MeasureTimeSeconds) 's']);
            % Turn off electrical attenuation.
            %sendCommand(obj,':SENSe:POWer:RF:EATTenuation:STATe OFF');
            % Set mechanical attenuation level to 0 dB
            sendCommand(obj,[':SENSe:POWer:RF:ATTenuation ',num2str(obj.Attenuation)]);
            % Turn IQ signal ranging to auto
            sendCommand(obj,':SENSe:VOLTage:IQ:RANGe:AUTO ON');
            % Turn off averaging
            sendCommand(obj,':SENSe:WAVeform:AVER OFF');
            % set to take one single measurement
            sendCommand(obj,':INIT:CONT OFF');
            % Set the endianness of returned data
            sendCommand(obj,':FORMat:BORDer NORMal');
            % Set the format of the returned data
            sendCommand(obj,':FORMat:DATA REAL,32');
            % Set samples per block to get
            %sendCommand(obj,'FCAP:BLOC 100');
            % Wait till operation is complete.
            obj.localWaitTillComplete();
            % Check if we have errors
            errors = obj.localDisplayInstrumentErrors();
        end
        
        function localWaitTillComplete(obj)
            % Wait until instrument operation is complete
            operationComplete = str2double(query(obj.dev,'*OPC?'));
            while ~operationComplete
                pause(0.005);
                operationComplete = str2double(query(obj.dev,'*OPC?'));
            end
        end
        
        function errors = sendCommand(obj,cmd)
            fprintf(obj.dev,cmd);
            errors = [];
            %localWaitTillComplete(obj);
            %errors = obj.localDisplayInstrumentErrors(); % Cannot call
            %this at specific times since instrument will hang
        end
        
        function overload = checkADCOverloadCondition(obj)
            % Part of STATUS QUESTIONABLE INTEGRITY
            bitIndx = 5; % 5th bit in status register
            instrumentError = query(obj.dev,'STAT:QUES:INT:COND?');
            % Check if we have an error
            bits = dec2binvec(str2double(instrumentError),16);
            if bits(bitIndx)
                disp('ADC Overload')
                overload = true;
            else
                overload = false;
            end
        end
        
        function clearConnectedDevices(~)
            g = instrfind;
            fclose(g); % Close connection to open device
            delete(g);
            %instrreset; % Reset all instruments
        end
        
        function ViewSpectrum(obj)
            obj.spectrumPlotRx = dsp.SpectrumAnalyzer;
            obj.spectrumPlotRx.SampleRate =  obj.SampleRate;
            obj.spectrumPlotRx.SpectrumType = 'Power density';
            obj.spectrumPlotRx.PowerUnits =  'dBm';
            obj.spectrumPlotRx.RBWSource = 'Property';
            obj.spectrumPlotRx.RBW = 1.3e3;
            obj.spectrumPlotRx.FrequencySpan = 'Span and center frequency';
            obj.spectrumPlotRx.Span = obj.SampleRate;
            obj.spectrumPlotRx.CenterFrequency = 0;
            obj.spectrumPlotRx.Window = 'Rectangular';
            obj.spectrumPlotRx.SpectralAverages = 10;
            obj.spectrumPlotRx.YLabel = 'PSD';
            obj.spectrumPlotRx.ShowLegend = false;
            obj.spectrumPlotRx.Title = 'Received Signal Spectrum: 10 MHz LTE Carrier';
            obj.spectrumPlotRx(obj.rxWaveform);
        end
        
        function enableSpectrumMode(obj)
            % Switch back to the spectrum analyzer view
            sendCommand(obj,':INSTrument:SELect SA');
            % Set mechanical attenuation level
            sendCommand(obj,[':SENSe:POWer:RF:ATTenuation ',num2str(obj.Attenuation)]);            
            % Set the center frequency, RBW and VBW and trigger
            sendCommand(obj,[':SENSe:FREQuency:CENTer ' num2str(obj.CenterFrequency)]);
            sendCommand(obj,[':SENSe:FREQuency:STARt ' num2str(obj.CenterFrequency-obj.SampleRate/2)]);
            sendCommand(obj,[':SENSe:FREQuency:STOP ' num2str(obj.CenterFrequency+obj.SampleRate/2)]);
            sendCommand(obj,[':SENSe:BANDwidth:RESolution ' num2str(200e3)]);
            sendCommand(obj,[':SENSe:BANDwidth:VIDeo ' num2str(200e3)]);
            % Continuous measurement
            sendCommand(obj,':INIT:CONT ON');
            % Trigger
            sendCommand(obj,'*TRG');
        end
        
        function errors = localDisplayInstrumentErrors(obj)
            errors = [];
            % Display any instrument errors
            instrumentError = query(obj.dev,'SYSTem:ERRor?');
            while ~contains(lower(instrumentError),'no error')
                warning('\tInstrument Error: %s',instrumentError);
                %fprintf('\tInstrument Error: %s',instrumentError);
                num = obj.processError(instrumentError);
                errors = [errors; num]; %#ok<AGROW>
                instrumentError = query(obj.dev,'SYSTem:ERRor:NEXT?');
            end
        end
        
        function errorNum= processError(~,errorString)
            loc = strfind(errorString,',');
            errorNum = str2double(errorString(1:loc));
        end
    end
    
end

