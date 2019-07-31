classdef gen80211aTestWaveform
    properties (Constant)
        %%
        fs  = 20e6 % sample rate
    end
    
    properties (Access = public)
        %%
        % carrier frequency
        fc
        % number of frames
        numPackets = 50
        % IEEE 802.11a Modulation and Coding Scheme [0-7]
        mcs = 2
        % Fix the WLAN frame length to a constant value? (true/false)
        constPktLen = true
        % Simulation seed
        % 0 - generate a random seed
        % xyz - seed is set to xyz
        seed = 0           
    end
    
    
    properties (Access = public) % derived properties
        %%
        SampleTime_rx
        random_delay 
        txPSDU
        txMPDU
        packetLen 
        txWaveform 
        MSDULenOctets 
        MSDULenBits          
        nht         
    end
    
    properties (Access = public)
        %% 
        noiseVar = 1e-6
        gain_per_packet
        rxWaveform
    end
    
    methods
        function obj = gen80211aTestWaveform(sim_settings, wlan_settings)
            mustBeMember(wlan_settings.fc,5180e6:20e6:5320e6);
            obj.fc = wlan_settings.fc;
            mustBeMember(wlan_settings.mcs,0:7);
            obj.mcs = wlan_settings.mcs;
            obj.constPktLen = wlan_settings.constPktLen;
            obj.seed = wlan_settings.seed;
            obj.numPackets = wlan_settings.numPackets;            
            obj.SampleTime_rx = 1/obj.fs;
            obj.snr = sim_settings.snr;
            
            % Generate Non-HT Waveform
            obj = obj.genTestWaveform(); 
            if (sim_settings.SIM_STUDY == true)
                % apply channel impairments
                obj = obj.applyImpairments(sim_settings);
            end
        end       
    end

    methods (Access = private)
        function obj = genTestWaveform(obj)
            % Generate 20 MHz Non-HT Waveform
            if (obj.seed == 0)
                obj.seed = int32(randi(intmax));
            end
            
            % If the data payload is of random length,
            % the minimum MSDU length is set to 250.
            % Otherwise, it is set to 2304.
            rng(obj.seed); 
            if (obj.constPktLen)
                obj.MSDULenOctets = 2304*ones(obj.numPackets, 1);
            else
                obj.MSDULenOctets = randi([250 2304], obj.numPackets, 1);            
            end
            rng(obj.seed);
            payload = randi([0 255], sum(obj.MSDULenOctets), 1);
            
            macConfig = wlanMACFrameConfig;
            macConfig.FrameType = 'Data';
            prev = 0;
            for ii = 1:obj.numPackets
                obj.nht{ii} = wlanNonHTConfig('MCS', obj.mcs, ...
                    'PSDULength', obj.MSDULenOctets(ii));
                                
                macConfig.SequenceNumber = ii;
                [obj.txMPDU{ii}, lengthMPDU] = wlanMACFrame(payload(prev+1:prev+obj.MSDULenOctets(ii)), macConfig);
                prev = prev+obj.MSDULenOctets(ii);
                obj.nht{ii}.PSDULength = lengthMPDU;                
                obj.txPSDU{ii} = reshape(de2bi(hex2dec(obj.txMPDU{ii}), 8)', [], 1);
                
                % WLAN waveform
                obj.txWaveform{ii} = wlanWaveformGenerator(obj.txPSDU{ii}, obj.nht{ii}, ...
                    'NumPackets',1,'IdleTime',20e-6).';
                obj.packetLen(ii) = length(obj.txWaveform{ii});                
            end
            obj.MSDULenBits = (obj.MSDULenOctets+28)*8; % take overhead into account
            obj.txWaveform = cell2mat(obj.txWaveform).';
            obj.txWaveform = obj.txWaveform(:);

            % Start of the transmission is random
            obj.random_delay = round(2^17*(0.15+0.1*rand()));
            prepend_sig = zeros(obj.random_delay, 1);
            obj.txWaveform = [prepend_sig; obj.txWaveform];           
        end
        
        function obj = applyImpairments(obj, sim_settings)
            % AWGN
            rng(obj.seed);    
            awgnChan = comm.AWGNChannel('SignalPower',var(obj.txWaveform));
            awgnChan.NoiseMethod = 'Signal to noise ratio (SNR)';
            awgnChan.SNR = obj.snr;        
            obj.rxWaveform = awgnChan(obj.txWaveform);    
            % frequency/phase/timing offsets
            pfo = comm.PhaseFrequencyOffset('SampleRate', obj.fs, 'FrequencyOffset', 500, 'PhaseOffset', 30);
            obj.rxWaveform = pfo(obj.rxWaveform);
                
            % add channel impairments based on SIM_MODE
            if ((sim_settings.SIM_MODE == 2) || (sim_settings.SIM_MODE == 3)) 
                % Pass Non-HT waveform through a SISO channel.  
                % The free-space path loss simulated is over a 
                % (a) transmitter-to-receiver separation distance of 3 m,
                % (b) maximum Doppler shift of 3 Hz and 
                % (c) an RMS path delay equal to 2x the sample time. 
                dist = 30;
                pathLoss = 10^(-log10(4*pi*dist*(obj.fc/physconst('LightSpeed'))))*1e3;                
                trms = 2/obj.fs;
                maxDoppShift = 3;                
                rng(obj.seed);    
                ch802 = comm.RayleighChannel('SampleRate',obj.fs,'MaximumDopplerShift',maxDoppShift,'PathDelays',trms);
                obj.rxWaveform = ch802(obj.rxWaveform)*pathLoss;    
            end
            
            % arbitrary gain per packet
            if (sim_settings.GAIN_MODE == 0)
                obj.gain_per_packet = ones(obj.numPackets, 1);  
                obj.rxWaveform = obj.txWaveform/150; % an arbitrary value to scale the entire waveform   
            elseif (sim_settings.GAIN_MODE == 1)
                % Interpolated Gaussian random values as a model of gain
                % evolution. Values are scaled based on default AD9361 gain 
                % table mappings.
                tmp_len = ceil(obj.numPackets/50)*50;            
                tmp_g = randn(1,tmp_len/5);
                tmp_g = interp(tmp_g, 5);
                tmp_g = tmp_g-min(tmp_g);
                tmp_g = tmp_g/max(tmp_g);
                tmp_g = round(tmp_g*65);
                g = tmp_g(1:obj.numPackets);

                % Gain per packet in linear scale.
                obj.gain_per_packet = 10.^(g./20);
            end
            prev = obj.random_delay;
            for ii = 1:obj.numPackets
                obj.rxWaveform(prev+(1:obj.packetLen(ii)), :) = ...
                    obj.gain_per_packet(ii)*obj.rxWaveform(prev+(1:obj.packetLen(ii)), :);
                prev = prev+obj.packetLen(ii);
            end
        end
    end
end