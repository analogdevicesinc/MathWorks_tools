classdef tuneAGC9361AGCTests < matlab.unittest.TestCase
    
    properties(TestParameter)
        MCSvals = {0:7};
    end
    
    %% Test Method Block
    methods (Test)
        
        %% 
        % Test function to verify the performance of the WLAN modem 
        % in the absence of AD9361 radio over AWGN channel
        function testWLAN_SimAWGN(testCase)
            % Simulation settings
            sim_settings.SIM_STUDY = true;
            sim_settings.SIM_MODE = 0;
            sim_settings.GAIN_MODE = 0;
            sim_settings.snr = 5;

            % WLAN settings
            wlan_settings.fc = 5200e6;
            wlan_settings.numPackets = 10;
            wlan_settings.constPktLen = false;
            wlan_settings.seed = 0;
            
            for nn = 1:length(testCase.MCSvals{1})
                log(testCase,1,['Testing with MCS value: ', num2str(testCase.MCSvals{1}(nn))]);
                
                wlan_settings.mcs = testCase.MCSvals{1}(nn);
                sim_obj = tuneAD9361AGC(sim_settings, wlan_settings);
                testCase.verifyLessThan(sim_obj.evm_per_frame, 1e-6*ones(1, wlan_settings.numPackets));
                testCase.verifyEqual(sim_obj.bErrs_per_frame, zeros(1, wlan_settings.numPackets));
                
                log(testCase,1,['Bit errors observed: ',num2str(sim_obj.bErrs_per_frame)]);
            end
        end
        
        %% 
        % Test function to verify the performance of the WLAN modem 
        % in the absence of AD9361 radio over fading channel
        function testWLAN_SimFading(testCase)
            % Simulation settings
            sim_settings.SIM_STUDY = true;
            sim_settings.SIM_MODE = 2;
            sim_settings.GAIN_MODE = 0;
            sim_settings.snr = 5;

            % WLAN settings
            wlan_settings.fc = 5200e6;
            wlan_settings.numPackets = 10;
            wlan_settings.constPktLen = false;
            wlan_settings.seed = 0;
            
            for nn = 1:length(testCase.MCSvals{1})
                log(testCase,1,['Testing with MCS value: ', num2str(testCase.MCSvals{1}(nn))]);
                
                wlan_settings.mcs = testCase.MCSvals{1}(nn);
                sim_obj = tuneAD9361AGC(sim_settings, wlan_settings);
                testCase.verifyLessThan(sim_obj.evm_per_frame, 1e-6*ones(1, wlan_settings.numPackets));
                testCase.verifyEqual(sim_obj.bErrs_per_frame, zeros(1, wlan_settings.numPackets));
                
                log(testCase,1,['Bit errors observed: ',num2str(sim_obj.bErrs_per_frame)]);
            end
        end
        
        %% 
        % Test function to verify the performance of the WLAN modem 
        % with AD9361 Rx simulink model-in-loop over AWGN channel
        function testWLAN_milAWGN(testCase)
            % Simulation settings
            sim_settings.SIM_STUDY = true;
            sim_settings.SIM_MODE = 1;
            sim_settings.GAIN_MODE = 0;
            sim_settings.snr = 5;

            % WLAN settings
            wlan_settings.fc = 5200e6;
            wlan_settings.mcs = 0;
            wlan_settings.numPackets = 10;
            wlan_settings.constPktLen = false;
            wlan_settings.seed = 0;
            
            % AD9361 settings
            ad9361_settings.AGC_MODE = 3;
            ad9361_settings.LOG_ADC_OUTPUT = 0;
            ad9361_settings.SAVE_LOG_DATA = 0;

            % AGC settings
            agc_settings.LMT_Hth = 30*16;
            agc_settings.LMT_Lth = 25*16;
            agc_settings.ADC_Ncycles = 4;
            agc_settings.ADC_Hth = 63;
            agc_settings.ADC_Lth = 56;
            agc_settings.AvgPwrMtr_Ncycles = 16;
            agc_settings.LowPwrTh = -40;
            agc_settings.EnergyLostLevel = 3;
            agc_settings.MaxIncrease = 63;
            agc_settings.AvgPwrLInc = 7;
            agc_settings.AvgPwrSInc = 4;
            agc_settings.AvgPwrLDec = 7;
            agc_settings.AvgPwrSDec = 6;
            agc_settings.AGCLockLevel = -7;
            
            % for nn = 1:length(testCase.MCSvals{1})
                log(testCase,1,['Testing with MCS value: ',wlan_settings.mcs]);
                
                sim_obj = tuneAD9361AGC(sim_settings, wlan_settings, ad9361_settings, agc_settings);
                testCase.verifyLessThan(sim_obj.evm_per_frame, 1e-6*ones(1, wlan_settings.numPackets));
                testCase.verifyEqual(sim_obj.bErrs_per_frame, zeros(1, wlan_settings.numPackets));
                
                log(testCase,1,['Bit errors observed: ',num2str(sim_obj.bErrs_per_frame)]);
            % end
        end
    end
end