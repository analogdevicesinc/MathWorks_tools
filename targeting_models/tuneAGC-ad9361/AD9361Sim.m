classdef AD9361Sim
    properties
        %%
        % AGC mode (applicable only when SIM_MODE is set to 1 or 3)
        % 0 - manual
        % 1 - fast attack
        % 2 - slow attack
        % 3 - fast during preamble, manual during data payload
        AGC_MODE = 3
        % Log output of ADC block? 1/0 - Y/N
        % The size of log-file will be significantly larger if set to 1
        % since ADC runs at a higher rate than the sample clock
        LOG_ADC_OUTPUT = 0
        % Save log-data to .mat file? 1/0 - Y/N
        SAVE_LOG_DATA = 1        
    end
    
    properties (Access = private)
        num_sims
        sig_filename
        testwaveform_fileloc
        folder_name
        model
        block
        rx_block
        logged_blocks        
        error_message
        log_data
        log_data_indices        
    end
    
    properties
        rxNonHT
        input_waveform
    end
    
    methods
        function obj = AD9361Sim(sim_settings, ad9361_settings, agc_settings)
            % local variables
            fs = obj.fs;
            M = obj.ovx(1);
            N = obj.ovx(2);
            SampleTime_rx = obj.SampleTime_rx;
            AGC_MODE = ad9361_settings.AGC_MODE;
            LOG_ADC_OUTPUT = ad9361_settings.LOG_ADC_OUTPUT;
            obj.folder_name = 'ad9361_rx_input_files';

            if ((sim_settings.SIM_MODE == 0) || (sim_settings.SIM_MODE == 2))
                %% Simulation mode #0 or #2 - no simulink-model-in-loop 
                obj.input_waveform = obj.rxPPDU; 
            else
                %% Simulation mode #1 or #3 - simulink-model-in-loop
                % generate all combinations of AGC settings
                [local_agc_settings, obj.num_sims] = obj.agc_settings_all_combos(agc_settings);

                % Enable logging for desired signals 
                obj.model = 'ad9361_rx_wlan_testbench';
                obj.block = 'ad9361_rx';
                load_system(obj.model); % load model into memory
                st_param = get_param(obj.model, 'ModelWorkspace');
                assignin(st_param,'SampleTime_rx', SampleTime_rx); % assign value to sample-time 
                obj = obj.gen_testWaveform_file(); % set Baseband file name
                obj.rx_block = strcat(obj.model, '/', obj.block);    

                obj.logged_blocks = {['ADC ' newline 'Overload ' newline 'Detector'],...
                    ['LMT ' newline 'Peak ' newline 'Detector'],...
                    'DDC_Filters_RX', 'In', 'Average Power Meter', 'AGC'};
                if (LOG_ADC_OUTPUT)
                    obj.logged_blocks{end+1} = 'ADC_RX';
                end
                num_logged_signals = obj.enable_signal_logging();
                save_system(obj.model);

                % Tune AGC settings and run the AD9361 simulink model, ...
                sim_time = ceil(1e4*length(obj.rxNonHT)/(M*fs/N))/1e4;
                WLAN_ad9361_simin = Simulink.SimulationInput.empty(obj.num_sims, 0);
                for idx = 1:obj.num_sims
                    WLAN_ad9361_simin(idx) = Simulink.SimulationInput(obj.model);
                    WLAN_ad9361_simin(idx) = WLAN_ad9361_simin(idx).setModelParameter('StopTime',sprintf('%f',sim_time));
                    WLAN_ad9361_simin(idx) = obj.tune_agc_settings(ad9361_settings.AGC_MODE, idx, WLAN_ad9361_simin(idx), local_agc_settings);
                end
                WLAN_ad9361_simout = parsim(WLAN_ad9361_simin, 'ShowProgress', 'on');
                % then, disable signal logging and save model
                obj.disable_signal_logging();
                save_system(obj.model);

                % Extract log-data
                for idx = 1:obj.num_sims
                    obj.error_message{idx} = WLAN_ad9361_simout(idx).ErrorMessage;
                    [obj.log_data{idx}, obj.log_data_indices{idx}] = obj.extract_log_data(num_logged_signals, WLAN_ad9361_simout(idx));
                    % Resample 9361 output to 1x rate for consumption by WLAN receiver
                    obj.input_waveform{idx} = resample(obj.log_data{idx}{obj.log_data_indices{idx}.AD9361_Output}.Data, N, M);                    
                end                
            end
            
            obj.AGC_MODE = ad9361_settings.AGC_MODE;
            obj.LOG_ADC_OUTPUT = ad9361_settings.LOG_ADC_OUTPUT;            
            obj.SAVE_LOG_DATA = ad9361_settings.SAVE_LOG_DATA;
        end
        
        %% function to determine all combinations of AGC settings to apply 
        function [local_agc_settings, num_combos] = agc_settings_all_combos(obj, agc_settings)
            AGC_fields = fields(agc_settings);
            tuned_settings = [];
            for ii = 1:length(AGC_fields)
                if (length(agc_settings.(AGC_fields{ii})) > 1)
                    tuned_settings = [tuned_settings; ii length(agc_settings.(AGC_fields{ii}))];
                end
            end
            if isempty(tuned_settings)
                local_agc_settings = agc_settings;
                num_combos = 1;
            else
                num_combos = prod(tuned_settings(:, 2));
                num_params = length(tuned_settings(:, 2));

                count = 1;
                sets = cell(num_params, 1);
                combos = zeros(num_combos, num_params);
                for ii = tuned_settings(:, 1).'
                    sets{count} = agc_settings.(AGC_fields{ii});
                    count = count+1;
                end
                combos_temp = cell(1,num_params);
                [combos_temp{:}] = ndgrid(sets{:});
                for ii = 1:num_params
                    combos(:, ii) = combos_temp{ii}(:);
                end

                for ii = 1:length(AGC_fields)
                    if ~ismember(ii, tuned_settings(:, 1))                    
                        local_agc_settings.(AGC_fields{ii}) = agc_settings.(AGC_fields{ii})*ones(1, num_combos);     
                    end                
                end
                count = 1;
                for ii = tuned_settings(:, 1).'
                    local_agc_settings.(AGC_fields{ii}) = combos(:, count).';  
                    count = count+1;
                end
            end
        end
        
        %% function to save the test waveform in a baseband file format 
        function obj = gen_testWaveform_file(obj)
            fc = obj.fc;
            fs = obj.fs;
            M = obj.ovx(1);
            N = obj.ovx(2);
            
            warning('off', 'MATLAB:MKDIR:DirectoryExists');
            mkdir(obj.folder_name);
            obj.sig_filename = char('testWaveform_'+regexprep(string(datetime),'[:-\s]','_')+'.bb');
            obj.testwaveform_fileloc = [pwd '\' obj.folder_name '\' obj.sig_filename];
            obj.rxNonHT = resample(obj.rxPPDU, M, N);
            bbw = comm.BasebandFileWriter(obj.testwaveform_fileloc,(M/N)*fs,fc);
            bbw.Metadata = struct('Date',date);
            bbw(obj.rxNonHT);
            release(bbw);
            
            top_level_blocks = find_system(obj.model);
            for ii = 1:length(top_level_blocks)
                blocks_path = strsplit(top_level_blocks{ii}, '/');
                if (length(blocks_path) < 2)
                    continue;
                end
                str = regexprep(blocks_path{2},'[\n\r-\s_]','');
                if strcmpi(str, 'BasebandFileReader')
                    set_param(top_level_blocks{ii},'Filename',obj.testwaveform_fileloc);
                    break;
                end
            end
            
            % configure filter parameters
            set_param([obj.model '/' obj.block],'RF',num2str(fc));
            set_param([obj.model '/' obj.block],'LO',num2str(fc));
            set_param([obj.model '/' obj.block],'Trf', ['SampleTime_rx' '/' num2str(M/N)])
        end
        
        %% function to programmatically enable logging selected blocks in
        % the Simulink model
        function num_logged_signals = enable_signal_logging(obj)
            num_logged_signals = 0;
            for ii = 1:length(obj.logged_blocks)
                rx_under_mask = [obj.rx_block '/' obj.logged_blocks{ii}]; 
                ph = get_param(rx_under_mask,'PortHandles');
                str = regexprep(obj.logged_blocks{ii},'[\n\r-\s_]','');
                switch (str)
                    case {'LMTPeakDetector', 'ADCOverloadDetector', 'DDCFiltersRX'}
                        set_param(ph.Outport(1),'DataLogging','on');
                        set_param(ph.Outport(2),'DataLogging','on');
                        num_logged_signals = num_logged_signals+2;
                    otherwise
                        set_param(ph.Outport(1),'DataLogging','on');                                            
                        num_logged_signals = num_logged_signals+1;
                end
            end    
        end
        
        %% function to programmatically disable logging selected blocks in
        % the Simulink model
        function disable_signal_logging(obj)
            for ii = 1:length(obj.logged_blocks)
                rx_under_mask = [obj.rx_block '/' obj.logged_blocks{ii}]; 
                ph = get_param(rx_under_mask,'PortHandles');
                str = regexprep(obj.logged_blocks{ii},'[\n\r-\s_]','');
                switch (str)
                    case {'LMTPeakDetector', 'ADCOverloadDetector', 'DDCFiltersRX'}
                        set_param(ph.Outport(1),'DataLogging','off');
                        set_param(ph.Outport(2),'DataLogging','off');                
                    otherwise
                        set_param(ph.Outport(1),'DataLogging','off');               
                end
            end
        end
        
        %% function to programmatically set AGC parameters in the Simulink
        % model
        function in = tune_agc_settings(obj, AGC_MODE, idx, in, AGC_settings)
            % Toggle manual switch to select AGC mode control input
            rx_top_level = find_system(obj.model);
            for ii = 1:length(rx_top_level)
                rx_top_level_path = strsplit(rx_top_level{ii}, '/');
                if (length(rx_top_level_path) < 2)
                    continue;
                end

                str = regexprep(rx_top_level_path{2},'[\n\r-\s_]','');
                if strcmpi(str, 'ManualSwitch')  
                    if (AGC_MODE == 3)
                        in = in.setBlockParameter(rx_top_level{ii}, 'sw', '0');
                    else
                        in = in.setBlockParameter(rx_top_level{ii}, 'sw', '1');
                    end
                elseif strcmpi(str, 'Attackmode')
                    if (AGC_MODE ~= 3)
                        if (AGC_MODE == 0)
                            in = in.setBlockParameter(rx_top_level{ii}, 'Attackmode', 'Manual');
                        elseif (AGC_MODE == 1)
                            in = in.setBlockParameter(rx_top_level{ii}, 'Attackmode', 'Fast');
                        elseif (AGC_MODE == 2)
                            in = in.setBlockParameter(rx_top_level{ii}, 'Attackmode', 'Slow');
                        end
                    end
                end
            end
            
            %% funtion to tune AGC settings
            rx_under_mask = find_system(obj.rx_block, 'LookUnderMasks', 'on', 'SearchDepth', 1);   

            for ii = 1:length(rx_under_mask)
                logged_block_path = strsplit(rx_under_mask{ii}, '/');
                if (length(logged_block_path) < 3)
                    continue;
                end

                str = regexprep(logged_block_path{3},'[\n\r-\s_]','');
                if strcmpi(str, 'AGC')    
                    % set AGC mask parameters
                    in = in.setBlockParameter(rx_under_mask{ii}, 'AGC_attack_delay', '1');
                    in = in.setBlockParameter(rx_under_mask{ii}, 'Max_Increase', num2str(AGC_settings.MaxIncrease(idx)));
                    in = in.setBlockParameter(rx_under_mask{ii}, 'EnergyLost', num2str(AGC_settings.EnergyLostLevel(idx)));
                    in = in.setBlockParameter(rx_under_mask{ii}, 'LowPower', num2str(AGC_settings.LowPwrTh(idx)));
                    in = in.setBlockParameter(rx_under_mask{ii}, 'AGC_G_inc_fast', num2str(AGC_settings.AvgPwrLInc(idx)));
                    in = in.setBlockParameter(rx_under_mask{ii}, 'AGC_G_inc_slow', num2str(AGC_settings.AvgPwrSInc(idx)));            
                    in = in.setBlockParameter(rx_under_mask{ii}, 'AGC_G_dec_fast', num2str(AGC_settings.AvgPwrLDec(idx)));
                    in = in.setBlockParameter(rx_under_mask{ii}, 'AGC_G_dec_slow', num2str(AGC_settings.AvgPwrSDec(idx)));
                    in = in.setBlockParameter(rx_under_mask{ii}, 'AGC_lock_level', num2str(AGC_settings.AGCLockLevel(idx)));            
                elseif strcmpi(str, 'LMTPeakDetector')  
                    in = in.setBlockParameter(rx_under_mask{ii}, 'HThreshold', num2str(AGC_settings.LMT_Hth(idx)));
                    in = in.setBlockParameter(rx_under_mask{ii}, 'LThreshold', num2str(AGC_settings.LMT_Lth(idx)));            
                elseif strcmpi(str, 'ADCOverloadDetector')  
                    in = in.setBlockParameter(rx_under_mask{ii}, 'Hthreshold', num2str(AGC_settings.ADC_Hth(idx)));
                    in = in.setBlockParameter(rx_under_mask{ii}, 'Lthreshold', num2str(AGC_settings.ADC_Lth(idx)));
                    in = in.setBlockParameter(rx_under_mask{ii}, 'Ncycles', num2str(AGC_settings.ADC_Ncycles(idx)));
                elseif strcmpi(str, 'AveragePowerMeter')  
                    in = in.setBlockParameter(rx_under_mask{ii}, 'Ncycles', num2str(AGC_settings.AvgPwrMtr_Ncycles(idx)));
                end                
            end
        end
        
        %% function to extract log data from each of the logged blocks in
        % the Simulink model
        function [log_data, indices] = extract_log_data(obj, num_logged_signals, WLAN_ad9361_sim)
            log_data = cell(num_logged_signals, 1);
            for ii = 1:num_logged_signals
                if (isprop(WLAN_ad9361_sim,'logsout'))
                    simData_sigObj = WLAN_ad9361_sim.logsout{ii};
                else
                    continue;
                end
                logged_block_path = strsplit(simData_sigObj.BlockPath.getBlock(1), '/');
                block_name = regexprep(logged_block_path{3},'[\n\r-\s_]','');        
                
                % Enable both output ports for some blocks and for the remaining,
                % enable the only output port
                switch block_name
                    case 'ADCOverloadDetector'
                        if (simData_sigObj.PortIndex == 1)
                           log_data{ii} = struct('Name', strcat(block_name,'Low'), 'Time', simData_sigObj.Values.Time);  
                           indices.ADC_Peak_Detector_Low = ii;
                        elseif (simData_sigObj.PortIndex == 2)
                           log_data{ii} = struct('Name', strcat(block_name,'High'), 'Time', simData_sigObj.Values.Time);  
                           indices.ADC_Peak_Detector_High = ii;
                        end
                    case 'LMTPeakDetector'
                        if (simData_sigObj.PortIndex == 1)
                           log_data{ii} = struct('Name', strcat(block_name,'High'), 'Time', simData_sigObj.Values.Time); 
                           indices.LMT_Peak_Detector_High = ii;
                        elseif (simData_sigObj.PortIndex == 2)
                           log_data{ii} = struct('Name', strcat(block_name,'Low'), 'Time', simData_sigObj.Values.Time); 
                           indices.LMT_Peak_Detector_Low = ii;
                        end
                    case 'DDCFiltersRX'
                        if (simData_sigObj.PortIndex == 1)
                           log_data{ii} = struct('Name', strcat(block_name,'OutputPwr'), 'Time', simData_sigObj.Values.Time);                   
                           indices.AD9361_Output_Power = ii;
                        elseif (simData_sigObj.PortIndex == 2)
                           log_data{ii} = struct('Name', strcat(block_name,'OutputSig'), 'Time', simData_sigObj.Values.Time);   
                           indices.AD9361_Output = ii;
                        end
                    otherwise
                        log_data{ii} = struct('Name', block_name, 'Time', simData_sigObj.Values.Time);                
                        if (strcmp(block_name, 'ADCRX'))
                            indices.ADC_Output = ii;
                        elseif strcmp(block_name, 'LPFRX')
                            indices.ADC_Input = ii;
                        elseif strcmp(block_name, 'In')
                            indices.AD9361_Input = ii;
                        elseif strcmp(block_name, 'RealImagtoComplex1')
                            indices.LMT_Output = ii;
                        elseif strcmp(block_name, 'AGC')
                            indices.AGC_Gain = ii;
                        elseif strcmp(block_name, 'AveragePowerMeter')
                            indices.Digital_Power = ii;
                        end                
                end
                
                % if log-data is in (1x1xN) matrix format, extract data along the third dimension
                if (numel(size(simData_sigObj.Values.Data)) == 3)
                    log_data{ii}.Data = permute(simData_sigObj.Values.Data(1,1,:),[3 1 2]);
                else
                    log_data{ii}.Data = simData_sigObj.Values.Data;
                end
            end
        end
    end
end