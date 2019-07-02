classdef gen80211aTestWaveform
    properties (Constant)
        %%
        % sample rate
        fs  = 20e6 
        % WLAN Toolbox functions operate over 1x-rate data.
        % Oversample signal prior to passing it through 9361 receiver Simulink model.
        ovx = [2 1] % ovx factor = ovx(1)/ovx(2)                
    end
    
    properties (Access = public)
        %%
        % carrier frequency
        fc
        % number of frames
        numFrames = 50
        % IEEE 802.11a Modulation and Coding Scheme [0-7]
        mcs = 2
        % Simulation seed
        % 0 - generate a random seed
        % xyz - seed is set to xyz
        seed = 0           
    end
    
    
    properties (Access = public) % derived properties
        SampleTime_rx
        txPPDULength 
        txPPDU 
        PSDULengthBytes 
        PSDULengthBits 
        txPSDU 
        nht 
        random_delay 
    end
    
    properties (Access = public)
        noiseVar = 1e-6
        gain_per_packet
        rxPPDU
    end
    
    methods
        function obj = gen80211aTestWaveform(sim_settings, wlan_settings)
            mustBeMember(wlan_settings.fc,5180e6:20e6:5320e6);
            obj.fc = wlan_settings.fc;
            mustBeMember(wlan_settings.mcs,0:7);
            obj.mcs = wlan_settings.mcs;
            obj.seed = wlan_settings.seed;
            obj.numFrames = wlan_settings.numFrames;            
            obj.SampleTime_rx = 1/obj.fs;
            obj.snr = sim_settings.snr;
            
            % Generate Non-HT Waveform
            obj = obj.genTestWaveform(); 
            % apply channel impairments
            obj = obj.applyImpairments(sim_settings);
        end       
    end

    methods (Access = private)
        function obj = genTestWaveform(obj)
            % Generate 20 MHz Non-HT Waveform
            if (obj.seed == 0)
                obj.seed = int32(randi(intmax));
            end
            
            % Data payload is of random length.
            % The minimum length of the packet is fixed at 500.
            rng(obj.seed);    
            obj.PSDULengthBytes = randi([500 4095], obj.numFrames, 1);
            obj.PSDULengthBits = obj.PSDULengthBytes*8;
            
            rng(obj.seed);    
            obj.txPSDU = randi([0 1], sum(obj.PSDULengthBits),1);
            prev = 0;
            obj.nht = cell(obj.numFrames, 1);
            for ii = 1:obj.numFrames
                obj.nht{ii} = wlanNonHTConfig('MCS', obj.mcs, ...
                    'PSDULength', obj.PSDULengthBytes(ii));
                
                % Create L-STF, L-LTF, and L-SIG preamble fields 
                % and non-HT data field.
                lstf = wlanLSTF(obj.nht{ii});
                lltf = wlanLLTF(obj.nht{ii});
                lsig = wlanLSIG(obj.nht{ii});
                obj.nht{ii}.PSDULength = obj.PSDULengthBytes(ii);
                nhtData = wlanNonHTData(obj.txPSDU(prev+(1:obj.PSDULengthBits(ii)), :), obj.nht{ii});
                idleTimeLen = length(lstf)*5; % idle-time = 40 us
                idleTime = zeros(idleTimeLen, 1);
                
                % Concatenate the individual fields to create a single PPDU waveform.
                obj.txPPDU{ii} = [lstf; lltf; lsig; nhtData; idleTime].';
                obj.txPPDULength(ii) = length(obj.txPPDU{ii});
                prev = prev+obj.PSDULengthBits(ii);
            end
            obj.txPPDU = cell2mat(obj.txPPDU);

            % Start of the transmission is random
            obj.random_delay = round(2^17*(0.15+0.1*rand()));
            prepend_sig = zeros(1, obj.random_delay);
            obj.txPPDU = [prepend_sig obj.txPPDU].';           
        end
        
        function obj = applyImpairments(obj, sim_settings)
            % add channel impairments based on SIM_MODE
            if ((sim_settings.SIM_MODE == 0) || (sim_settings.SIM_MODE == 1))
                obj.gain_per_packet = ones(obj.numFrames, 1); % uniform gain per packet    
                obj.rxPPDU = obj.txPPDU/150; % an arbitrary value to scale the entire waveform   
            else
                % Pass Non-HT waveform through a SISO channel.  
                % The free-space path loss simulated is over a 
                % (a) transmitter-to-receiver separation distance of 3 m,
                % (b) maximum Doppler shift of 3 Hz and 
                % (c) an RMS path delay equal to 2x the sample time. 
                dist = 3;
                pathLoss = 10^(-log10(4*pi*dist*(obj.fc/3e8)))*1e3;
                trms = 2/obj.fs;
                maxDoppShift = 3;                
                rng(obj.seed);    
                ch802 = comm.RayleighChannel('SampleRate',obj.fs,'MaximumDopplerShift',maxDoppShift,'PathDelays',trms);
                
                % AWGN
                rng(obj.seed);    
                awgnChan = comm.AWGNChannel('SignalPower',var(obj.txPPDU));
                awgnChan.NoiseMethod = 'Signal to noise ratio (SNR)';
                awgnChan.SNR = obj.snr;        
                obj.rxPPDU = awgnChan(ch802(obj.txPPDU))*pathLoss;    
                
                % arbitrary gain per packet
                if (sim_settings.GAIN_MODE == 0)
                    obj.gain_per_packet = ones(obj.numFrames, 1);     
                elseif (sim_settings.GAIN_MODE == 1)
                    % interpolated Gaussian random values as a
                    % model of gain evolution
                    tmp_len = ceil(obj.numFrames/50)*50;            
                    tmp_g = randn(1,tmp_len/5);
                    tmp_g = interp(tmp_g, 5);
                    tmp_g = tmp_g-min(tmp_g);
                    tmp_g = tmp_g/max(tmp_g);
                    tmp_g = round(tmp_g*65);
                    g = tmp_g(1:obj.numFrames);
                    
                    % Gain per packet in linear scale.
                    % Values are scaled based on AD9361 gain table
                    % mappings.
                    obj.gain_per_packet = 10.^(g./20);
                end
                prev = obj.random_delay;
                for ii = 1:obj.numFrames
                    obj.rxPPDU(prev+(1:obj.txPPDULength(ii)), :) = ...
                        obj.gain_per_packet(ii)*obj.rxPPDU(prev+(1:obj.txPPDULength(ii)), :);
                    prev = prev+obj.txPPDULength(ii);
                end        
            end
        end
    end
end