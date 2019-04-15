classdef DeviceConfig < matlab.unittest.TestCase
    
    properties (Abstract)
        RxFrequencyCorrectionFactor
    end
    
    methods
        %% N9030A
        function sdrReceiver = ConfigureN9030A(obj,sdrReceiver,Rx)
            sdrReceiver.IP = Rx.Address;
            sdrReceiver.SampleRate = Rx.SamplingRate;
            sdrReceiver.EnableSpectrumViewAfterMeasurement = true;
            sdrReceiver.Attenuation = Rx.Gain;
            sdrReceiver.Setup(obj.RXBufferSize);
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
        function sdrTransmitter = ADISDRTx(~,sdrTransmitter,Tx,dataTX)
            sdrTransmitter.uri = Tx.Address;
            sdrTransmitter.EnableCyclicBuffers = true;
            sdrTransmitter.AttenuationChannel0 = Tx.Gain;
            if ~contains(class(sdrTransmitter),'ADRV9009')
                sdrTransmitter.SamplingRate = Tx.SamplingRate;
                if isfield(Tx,'CustomFilterFilename')
                    sdrTransmitter.EnableCustomFilter = true;
                    sdrTransmitter.CustomFilterFileName = Tx.CustomFilterFilename;
                end
            else
                if isfield(Tx,'CustomProfileFilename')
                    sdrTransmitter.EnableCustomProfile = true;
                    sdrTransmitter.CustomProfileFileName = Tx.CustomProfileFilename;
                end
            end
            % Resample
            %                     dataTX = resample(double(dataTX),testCase.TxSamplingRate,...
            %                         testCase.RxSamplingRate/2);
            %                     dataTX = int16(2^15.*double(dataTX)./max(abs(double(dataTX))));
            % Transmit
            sdrTransmitter(dataTX)
        end
        %% ADI Rx SDR
        function sdrReceiver = ADISDRRx(~,sdrReceiver,Rx)
            sdrReceiver.uri = Rx.Address;
            sdrReceiver.kernelBuffersCount = 1;
            if ~contains(class(sdrReceiver),'ADRV9009')
                sdrReceiver.GainControlModeChannel0 = Rx.GainMode;
                if contains(lower(Rx.GainMode),'manual')
                    sdrReceiver.GainChannel0 = Rx.Gain;
                end
                sdrReceiver.SamplingRate = Rx.SamplingRate;
                if isfield(Rx,'CustomFilterFilename')
                    sdrReceiver.EnableCustomFilter = true;
                    sdrReceiver.CustomFilterFileName = Rx.CustomFilterFilename;
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
            if strcmpi(class(sdrTransmitter),'N5182B')
                % N5182B
                obj.ConfigureN5182B(sdrTransmitter,Tx,dataTX);               
            else
                % SDRs
                sdrTransmitter.CenterFrequency = Tx.CenterFrequency;
                if strcmp(obj.author,'MathWorks')
                    % MathWorks
                    obj.MathWorksSDRTx(sdrTransmitter,Tx,dataTX);
                else
                    % ADI
                    obj.ADISDRTx(sdrTransmitter,Tx,dataTX);
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
                ConfigureN9030A(obj,sdrReceiver,Rx)
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

