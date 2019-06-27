classdef DeviceConfig < matlab.unittest.TestCase
    
    properties (Abstract)
        RxFrequencyCorrectionFactor
    end
    
    properties
        DSG3060ManualFileWrite = false;
    end
    
    methods
        %% DSG3060
        function sdrTransmitter = ConfigureDSG3060(obj,sdrTransmitter,...
                Tx,dataTX)
            sdrTransmitter.USB = Tx.Address;
            sdrTransmitter.SampleRate = Tx.SamplingRate;
            sdrTransmitter.OutputPower = Tx.Gain;
            sdrTransmitter.Setup();
            dataTX = double(dataTX)./max(abs(double(dataTX)));
            if ~obj.DSG3060ManualFileWrite
                sdrTransmitter.CreateWaveformFile(dataTX);
                fprintf('Load generated file onto DSG3060 with name %s\n',...
                    sdrTransmitter.filename);
                disp('Hit enter once file is loaded onto DSG3060');
                pause();
                obj.DSG3060ManualFileWrite = true;
            end
            sdrTransmitter.EnableTX();
        end
        %% E8267D
        function sdrTransmitter = ConfigureE8267D(~,sdrTransmitter,...
                Tx,dataTX)
            sdrTransmitter.IP = Tx.Address;
            sdrTransmitter.SampleRate = Tx.SamplingRate;
            sdrTransmitter.OutputPower = Tx.Gain;
            sdrTransmitter.Setup(length(dataTX));
            dataTX = double(dataTX)./max(abs(double(dataTX)));
            sdrTransmitter.EnableTX(dataTX);
        end
        
        %% N9030A
        function sdrReceiver = ConfigureN9030A(~,sdrReceiver,Rx)
            sdrReceiver.IP = Rx.Address;
            sdrReceiver.SampleRate = Rx.SamplingRate;
            sdrReceiver.EnableSpectrumViewAfterMeasurement = true;
            sdrReceiver.Attenuation = Rx.Gain;
            %             sdrReceiver.Setup(obj.RXBufferSize);
            sdrReceiver.Setup(2^18);
        end
        %% N5182B
        function sdrTransmitter = ConfigureN5182B(~,sdrTransmitter,...
                Tx,dataTX)
            sdrTransmitter.IP = Tx.Address;
            sdrTransmitter.SampleRate = Tx.SamplingRate;
            sdrTransmitter.OutputPower = Tx.Gain;
            sdrTransmitter.Setup(length(dataTX));
            dataTX = double(dataTX)./max(abs(double(dataTX)));
            sdrTransmitter.EnableTX(dataTX);
        end
        %% MathWorks Tx SDR
        function sdrTransmitter = MathWorksSDRTx(~,sdrTransmitter,Tx,dataTX)
            if isprop(sdrTransmitter,'RadioID')
                sdrTransmitter.RadioID = Tx.Address;
            else
                sdrTransmitter.IPAddress = Tx.Address;
            end
            sdrTransmitter.ShowAdvancedProperties = true;
            sdrTransmitter.BasebandSampleRate = Tx.SamplingRate;
            sdrTransmitter.Gain = Tx.Gain;
            sdrTransmitter.transmitRepeat(dataTX);
        end
        %% MathWorks Rx SDR
        function sdrReceiver = MathWorksSDRRx(obj,sdrReceiver,Rx)
            if isprop(sdrReceiver,'RadioID')
                sdrReceiver.RadioID = Rx.Address;
            else
                sdrReceiver.IPAddress = Rx.Address;
            end
            sdrReceiver.GainSource = Rx.GainMode;
            if contains(lower(Rx.GainMode),'manual')
                sdrReceiver.Gain = Rx.Gain;
            end
            sdrReceiver.BasebandSampleRate = Rx.SamplingRate;
            sdrReceiver.OutputDataType = 'int16';
            sdrReceiver.ShowAdvancedProperties = true;
            sdrReceiver.FrequencyCorrection = ...
                obj.RxFrequencyCorrectionFactor;
        end
        %% ADI Tx SDR
        function sdrTransmitter = ADISDRTx(~,sdrTransmitter,Tx,dataTX,Rx)
            sdrTransmitter.uri = Tx.Address;
            sdrTransmitter.EnableCyclicBuffers = true;
            sdrTransmitter.AttenuationChannel0 = Tx.Gain;
            if ~(contains(class(sdrTransmitter),'Pluto') || ...
                    contains(class(sdrTransmitter),'AD9364') )
                sdrTransmitter.AttenuationChannel1 = Tx.Gain;
            end
            if ~contains(class(sdrTransmitter),'ADRV9009')
                if isfield(Tx,'CustomFilterFilename')
                    sdrTransmitter.EnableCustomFilter = true;
                    sdrTransmitter.CustomFilterFileName = Tx.CustomFilterFilename;
                else
                    if isprop(sdrTransmitter,'CustomFilterFileName') && ...
                            ~sdrTransmitter.EnableCustomFilter
                        sdrTransmitter.SamplingRate = Tx.SamplingRate;
                    end
                end
            else
                if isfield(Tx,'CustomProfileFilename')
                    sdrTransmitter.EnableCustomProfile = true;
                    sdrTransmitter.CustomProfileFileName = Tx.CustomProfileFilename;
                end
            end
            % Resample
            dataTX = resample(double(dataTX),Tx.SamplingRate,...
                Rx.SamplingRate);
            dataTX = int16(2^15.*double(dataTX)./max(abs(double(dataTX))));
            % Transmit
            sdrTransmitter(dataTX);
        end
        %% ADI Rx SDR
        function sdrReceiver = ADISDRRx(~,sdrReceiver,Rx)
            sdrReceiver.uri = Rx.Address;
            sdrReceiver.kernelBuffersCount = 1;
            if ~contains(class(sdrReceiver),'ADRV9009')
                sdrReceiver.GainControlModeChannel0 = Rx.GainMode;
                if contains(lower(Rx.GainMode),'manual')
                    sdrReceiver.GainChannel0 = Rx.Gain;
                    if ~(contains(class(sdrReceiver),'Pluto') || ...
                            contains(class(sdrReceiver),'AD9364') )
                        sdrReceiver.GainChannel0 = Rx.Gain;
                    end
                end
                if isfield(Rx,'CustomFilterFilename')
                    sdrReceiver.EnableCustomFilter = true;
                    sdrReceiver.CustomFilterFileName = Rx.CustomFilterFilename;
                else
                    if isprop(sdrReceiver,'CustomFilterFileName') && ...
                            ~sdrReceiver.EnableCustomFilter
                        sdrReceiver.SamplingRate = Rx.SamplingRate;
                    end
                end
            else
                sdrReceiver.GainControlMode = Rx.GainMode;
                if contains(lower(Rx.GainMode),'manual')
                    sdrReceiver.GainChannel0 = Rx.Gain;
                end
                if isfield(Rx,'CustomProfileFilename')
                    sdrReceiver.EnableCustomProfile = true;
                    sdrReceiver.CustomProfileFileName = Rx.CustomProfileFilename;
                end
            end
        end
        
        %% General set up
        function [sdrTransmitter, sdrReceiver] = ConfigureDevices(obj,...
                Tx, Rx, ExtendedTxParams,ExtendedRxParams, dataTX)
            %% TX
            sdrTransmitter = Tx.Device();
            sdrTransmitter.CenterFrequency = Tx.CenterFrequency;
            % Add custom parameters to object
            if ~isempty(ExtendedTxParams)
                fn = fieldnames(ExtendedTxParams);
                for f =1:length(fn)
                    sdrTransmitter.(fn{f}) = ExtendedTxParams.(fn{f});
                end
            end
            switch class(sdrTransmitter)
                case 'N5182B'
                    obj.ConfigureN5182B(sdrTransmitter,Tx,dataTX);
                case 'E8267D'
                    obj.ConfigureE8267D(sdrTransmitter,Tx,dataTX);
                case 'DSG3060'
                    obj.ConfigureDSG3060(sdrTransmitter,Tx,dataTX);
                otherwise
                    % SDRs
                    sdrTransmitter.CenterFrequency = Tx.CenterFrequency;
                    if strcmp(obj.author,'MathWorks')
                        % MathWorks
                        obj.MathWorksSDRTx(sdrTransmitter,Tx,dataTX);
                    else
                        % ADI
                        obj.ADISDRTx(sdrTransmitter,Tx,dataTX,Rx);
                    end
            end
            
            %% RX
            sdrReceiver = Rx.Device();
            sdrReceiver.CenterFrequency = Rx.CenterFrequency;
            % Add custom parameters to object
            if ~isempty(ExtendedRxParams)
                fn = fieldnames(ExtendedRxParams);
                for f =1:length(fn)
                    sdrReceiver.(fn{f}) = ExtendedRxParams.(fn{f});
                end
            end
            if strcmpi(class(sdrReceiver),'N9030A')
                % N9030A
                ConfigureN9030A(obj,sdrReceiver,Rx);
            else
                % SDRs
                sdrReceiver.SamplesPerFrame = obj.RXBufferSize;
                if strcmp(obj.author,'MathWorks')
                    % MathWorks
                    obj.MathWorksSDRRx(sdrReceiver,Rx);
                else
                    % ADI
                    obj.ADISDRRx(sdrReceiver,Rx);
                end
            end
        end
        
        
    end
end

