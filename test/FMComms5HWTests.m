classdef FMComms5HWTests < matlab.unittest.TestCase
    properties
        uri = 'ip:192.168.3.2'
        CenterFrequency = 2.4e9;
        SamplingRate = 3e6;
        DoPlots = false;
        LogfileName = 'TestData.mat';
        InnerLoopIterations = 10;
    end
    
    methods(TestClassSetup)
    end
    
    methods(TestClassTeardown)
    end
    
    methods(Static)
        function offsets = CheckPhaseDifferences(a,b,c,d)
            %% Determine channel phase differences
            angleW = @(x) unwrap(angle(x));
            
            offsets = zeros(1,3);
            ref = mean(angleW(double(a)));
            offsets(1) = mean(angleW(double(b))) - ref;
            offsets(2) = mean(angleW(double(c))) - ref;
            offsets(3) = mean(angleW(double(d))) - ref;
            offsets = offsets.*180/pi;
            fprintf(...
                'Measured offsets degrees:\nChannel1: %2.2f\nChannel2: %2.2f\nChannel3: %2.2f\n',...
                offsets(1),offsets(2),offsets(3));
        end
        
        function PlotTimeDomain(a,b,c,d)
            figure(1);
            subplot(2,1,1);
            plot(real([a,b,c,d]));
            xlim([length(a)-1000 length(a)])
            subplot(2,1,2);
            plot(imag([a,b,c,d]));
            xlim([length(a)-1000 length(a)])
        end
        
        function PlotOffsets(Frequencies,offsets,offsetsVar,indxFreq,indxSamp,str)
            figure(2);
            plot(Frequencies(1:indxFreq),squeeze(offsets(1:indxFreq,indxSamp,:)));
            hold on;
            xlabel('Frequencies');
            ylabel('Channel offsets');
            legend('Channel 1','Channel 2','Channel 3');
            grid on;
            hold off;
            saveas(gcf, ['SyncOffsetsTestError_',datestr(str)], 'fig');

%             figure(3);
%             f = repmat( Frequencies(1:indxFreq), 1, 3);
%             errorbar(f,...
%                 squeeze(offsets(1:indxFreq,indxSamp,:)),...
%                 squeeze(offsetsVar(1:indxFreq,indxSamp,:)) );
%             hold on;
%             xlabel('Frequencies');
%             ylabel('Channel offsets');
%             legend('Channel 1','Channel 2','Channel 3');
%             grid on;
%             hold off;
%             saveas(gcf, ['SyncOffsetsTest_',datestr(str)], 'fig');
        end
        
    end
    
    methods
        
        function offsets = RunPhaseSyncedDesign(testCase)
            
            %% Set up device
            fm5 = adi.FMComms5.Rx;
            fm5.uri = testCase.uri;
            fm5.channelCount = 8;
            fm5.EnablePhaseSync = true;
            fm5.GainControlModeChipA = 'manual';
            fm5.GainControlModeChipB = 'manual';
            fm5.GainChipA = 20;
            fm5.GainChipB = 20;
            fm5.CenterFrequency = testCase.CenterFrequency;
            fm5.SamplingRate = testCase.SamplingRate;
            fm5.kernelBuffersCount = 1;
            
            %% Get data
            for k=1:testCase.InnerLoopIterations
                [a,b,c,d] = fm5();
                if testCase.DoPlots
                    testCase.PlotTimeDomain(a,b,c,d);
                end
            end
            
            %% Determine channel phase differences
            offsets = testCase.CheckPhaseDifferences(a,b,c,d);
            
            %% Cleanup
            clear fm5;
            
        end
        
    end
    
    methods(Test)
        
        function testPhaseSync(testCase)
            
            Frequencies = [0.1,0.2,0.4,1,2,3,4].*1e9;
            SamplingRates = [10e6, 1e6];
            AveragesPerFrequency = 2;
            testCase.DoPlots = true;
            
            str = now;
            Channels = 4;
            offsets = zeros(length(Frequencies),length(SamplingRates),Channels-1);
            offsetsVar = zeros(length(Frequencies),length(SamplingRates),Channels-1);
            s1 = repmat('#',1,10);
            s2 = repmat('//',1,10);
            % Sample rate loop
            for indxSamp = 1:length(SamplingRates)
                fprintf('%s\nTesting Sample Rate: %d MHz\n',s1,SamplingRates(indxSamp)/1e6);
                testCase.SamplingRate = SamplingRates(indxSamp);
                % Frequencies loop
                for indxFreq = 1:length(Frequencies)
                    fprintf('%s\nTesting LO: %d MHz\n',s2,Frequencies(indxFreq)/1e6);
                    testCase.CenterFrequency = Frequencies(indxFreq);
                    % Average loop
                    offsetToAvg = zeros(AveragesPerFrequency,Channels-1);
                    for avg = 1:AveragesPerFrequency
                        offsetToAvg(avg,:) = testCase.RunPhaseSyncedDesign();
                    end
                    offsets(indxFreq,indxSamp,:) = mean(offsetToAvg,1);
                    offsetsVar(indxFreq,indxSamp,:) = std(offsetToAvg);
                    % Save logfile
                    save(testCase.LogfileName,'offsets','offsetsVar',...
                        'Frequencies','SamplingRates','indxFreq','indxSamp');
                    testCase.PlotOffsets(Frequencies,offsets,offsetsVar,...
                        indxFreq,indxSamp,str);
                    
                end
            end
            
        end
        
    end
end
