classdef HardwareTestGeneric < LTETests & DeviceRuntime ...
        & Calibration
    
    properties
        author = 'MathWorks';
        LoopIterationsPerFrequency = 10;
        RXBufferSize = 2^19;
        EnabledCalibration = true;
        uriTX
        uriRX
        EnableCustomFilter
        EnableCustomProfile
        ProfileFilename
        TxSamplingRate
        RxSamplingRate
        LTEFrequencyCorrectionAcrossRuns = false;
    end
    
    properties (Hidden)
        RxFrequencyCorrectionFactor = 0;
        CalibrationLoopIterations = 10;
        CalibrationFrequencyToleranceHz = 0.1;
    end
    
    methods(Static)
        
        function saveToJSON(filename,data)
            jsonStr = jsonencode(data);
            filename = fullfile('logs',filename);
            if exist('logs','dir') ~= 7
                mkdir('log');
            end
            fid = fopen(filename, 'w');
            if fid == -1, error('Cannot create JSON file'); end
            fwrite(fid, jsonStr, 'char');
            fclose(fid);
        end
        
        function saveToJSONExtended(filename,data)
            jsonStr = [];
            for line = 1:length(data)
                jsonStr = [jsonStr newline jsonencode(data(line))]; %#ok<AGROW>
            end
            filename = fullfile('logs',filename);
            fid = fopen(filename, 'w');
            if fid == -1, error('Cannot create JSON file'); end
            fwrite(fid, jsonStr, 'char');
            fclose(fid);
        end
        
    end
    
    methods
        
        function InstrumentReset(~)
            g = instrfind; %#ok<NASGU>
            instrreset;
        end
        
        function CheckTestInput(~,Tx,Rx)
            if ~isfield(Tx,'Device')
                error('Missing Tx Device');
            end
            if ~isfield(Tx,'SamplingRate')
                error('Missing Tx SamplingRate');
            end
            if ~isfield(Tx,'Gain')
                error('Missing Tx Gain');
            end
            if ~isfield(Tx,'Address')
                error('Missing Tx Address');
            end
            
            if ~isfield(Rx,'Device')
                error('Missing Rx Device');
            end
            if ~isfield(Rx,'SamplingRate')
                error('Missing Rx SamplingRate');
            end
            if ~isfield(Rx,'Gain')
                error('Missing Rx Gain');
            end
            if ~isfield(Rx,'Address')
                error('Missing Rx Address');
            end
            if ~isfield(Rx,'GainMode')
                error('Missing Rx GainMode');
            end
        end
        
        function [data,logs] = SDRLoopbackLTEEVMTest(testCase,...
                LTEMode,...
                Frequencies,Tx,Rx,...
                ExtendedTxParams,ExtendedRxParams,...
                testname)
            
            import matlab.unittest.diagnostics.FigureDiagnostic
            import matlab.unittest.diagnostics.FileArtifact;
            
            % Check inputs to make sure everything is defined
            testCase.CheckTestInput(Tx,Rx);
            
            runs = testCase.LoopIterationsPerFrequency;
            
            %% Run test
            evmMeanResults = zeros(size(Frequencies));
            evmPeakResults = zeros(size(Frequencies));
            evmMeanResultsStd = zeros(size(Frequencies));
            evmPeakResultsStd = zeros(size(Frequencies));
            
            logs = [];
            
            removeIndxs = [];
            for indx = 1:length(Frequencies)
                
                Tx.CenterFrequency = fix(Frequencies(indx));
                Rx.CenterFrequency = fix(Frequencies(indx));
                evmResults = zeros(runs,2);
                removeRuns = [];
                
                % Reset LTE offset calibration
                testCase.FrequencyOffset = 0;
                % Calibrate
                if testCase.EnabledCalibration
                    testCase.InstrumentReset();
                    Tx = testCase.Calibrate(Tx,Rx,ExtendedTxParams,ExtendedRxParams);
                end
                
                for k=1:runs
                    if testCase.LTEFrequencyCorrectionAcrossRuns
                        testCase.log(2,'Updating frequency offset with previously estimated value');
                        Tx.CenterFrequency = Tx.CenterFrequency - ...
                            double(int64(testCase.FrequencyOffset));
                    end
                    try
                        s = repmat('#',1,10);
                        testCase.log(1,sprintf('%s\nLO frequency %d (%d of %d) | Run %d of %d\n%s\n',...
                            s,Frequencies(indx),indx,length(Frequencies),...
                            k,runs,s));
                        % Instrument Reset
                        testCase.InstrumentReset();
                        % TX
                        [eNodeBOutput, config] = testCase.TransmitterLTE(LTEMode);
                        % Hardware
                        burstCaptures = testCase.DeviceToDevice(...
                            Tx,Rx,...
                            ExtendedTxParams,ExtendedRxParams,...
                            eNodeBOutput);
                        % RX
                        evmResults(k,:) = testCase.ReceiverLTE(LTEMode, config, burstCaptures,eNodeBOutput);
                    catch ME
                        warning(['Run failure at run ',num2str(k),', will remove in post processing']);
                        disp(ME);
                        removeRuns = [removeRuns;k]; %#ok<AGROW>
                    end
                    testCase.log(2,['logging partial results to ',testname,'.mat']);
                    save([testname,'.mat'],'evmResults','Frequencies','indx',...
                        'evmMeanResults','evmPeakResults','evmMeanResultsStd',...
                        'evmPeakResultsStd');
                end
                evmResults(removeRuns,:) = [];
                if isempty(evmResults)
                    removeIndxs = [removeIndxs; indx]; %#ok<AGROW>
                    warning(['Loop failure at loop ',num2str(indx),', will remove in post processing']);
                    continue;
                end
                
                evmMeanResults(indx) = mean(evmResults(:,1));
                evmPeakResults(indx) = mean(evmResults(:,2));
                evmMeanResultsStd(indx) = std(evmResults(:,1));
                evmPeakResultsStd(indx) = std(evmResults(:,2));
                
            end
            
            % Remove failed test cases
            evmMeanResults(removeIndxs) = [];
            evmPeakResults(removeIndxs) = [];
            evmMeanResultsStd(removeIndxs) = [];
            evmPeakResultsStd(removeIndxs) = [];
            Frequencies(removeIndxs) = [];
            
            %% Logs
            data = struct;
            data.testname = testname;
            data.testdate = datestr(now);
            data.Frequencies = Frequencies;
            data.evmMeanResults = evmMeanResults;
            data.evmMeanResultsStd = evmMeanResultsStd;
            data.evmPeakResults = evmPeakResults;
            data.evmPeakResultsStd = evmPeakResultsStd;
            ml = ver('MATLAB'); data.matlab_version = ml.Release(2:end-1);
            
            %% Plots
            fig1 = figure;
            fig2 = figure;
            figure(fig1);
            errorbar(Frequencies./1e9, evmMeanResults, evmMeanResultsStd);
            xlabel('LO Frequency (GHz)');
            ylabel('EVM % Mean');
            figure(fig2);
            errorbar(Frequencies./1e9, evmPeakResults, evmPeakResultsStd);
            xlabel('LO Frequency (GHz)');
            ylabel('EVM % Peak');
            testCase.log(FigureDiagnostic(fig1,'Formats',{'fig'},'Prefix',[testname,'_MeanEVM_']));
            testCase.log(FigureDiagnostic(fig2,'Formats',{'fig'},'Prefix',[testname,'_PeakEVM_']));
            savefig(fig1,['logs/',testname,'_MeanEVM'])
            savefig(fig2,['logs/',testname,'_PeakEVM'])
            
        end
    end
    
    
end
