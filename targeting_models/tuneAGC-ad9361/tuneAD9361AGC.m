classdef tuneAD9361AGC < AD9361TRx & gen80211aTestWaveform & demod80211aTestWaveform
    properties (Access = public)
        %%
        % Toggle SIM_STUDY to control whether a simulation study or 
        % a physical experiments-based study using a radio is conducted 
        % SIM_STUDY - true/false 
        SIM_STUDY = true    
        % SIM_MODE controls the simulation mode as follows:
        %   value  |     channel     |   radio   
        %---------------------------------------
        %     0    |   AWGN          |    No
        %     1    |   AWGN          |    Yes
        %     2    |   AWGN+Fading   |    No
        %     3    |   AWGN+Fading   |    Yes
        SIM_MODE = 3    
        % GAIN_MODE controls whether the simulated gain applied to each
        % packet is constant or varying (applicable when SIM_STUDY is 
        % set to true and SIM_MODE is set to 1 or 3)
        % 0 - uniform
        % 1 - non-uniform
        % If GAIN_MODE is set to 1, but SIM_MODE is set to 0 or 2, no AGC
        % is applied to the received signal and therefore, more bad packets
        % might be received than what is expected.
        GAIN_MODE = 1
        % SNR (dB) of the received test waveform (applicable when SIM_STUDY 
        % is set to true)
        snr
    end
    
    methods
        %%
        % sim_settings needs to have the following fields:
        % SIM_STUDY - see above
        % SIM_MODE - see above
        % GAIN_MODE - see above
        % snr - SNR (dB)
        %
        % wlan_settings needs to have the following fields:
        % fc - carrier frequency
        % numPackets - number of WLAN frames
        % mcs - WLAN's MCS Index
        % seed - 0/xyz (0 - random seed; xyz - seed value)        
        % See gen80211aTestWaveform.m for more details.
        %
        % ad9361_settings needs to have the following fields:
        % AGC_MODE - AGC mode (manual/slow/fast/receiver control)
        % LOG_ADC_OUTPUT - true/false (Toggle to log ADC block - It is 
        % suggested that this quantity is set to false unless the number of
        % simulated packets is small. ADC runs at a higher rate than the 
        % sample clock. So, the size of the log file will be significantly 
        % larger if set to true.)
        % SAVE_LOG_DATA - true/false (Toggle to save log data to file)
        %
        % See AD9361TRx.m for more details.
        function obj = tuneAD9361AGC(sim_settings, wlan_settings, varargin)
            % generate IEEE 802.11a compliant test waveform
            obj = obj@gen80211aTestWaveform(sim_settings, wlan_settings);
            
            % apply AGC settings to the model and run simulations
            obj = obj@AD9361TRx(sim_settings, varargin);
            
            % demodulate IEEE 802.11a compliant test waveform
            obj = obj@demod80211aTestWaveform(sim_settings);
            
            obj.SIM_STUDY = sim_settings.SIM_STUDY;
            obj.SIM_MODE = sim_settings.SIM_MODE;
            obj.GAIN_MODE = sim_settings.GAIN_MODE;
            obj.snr = sim_settings.snr;
        end
    end
end