classdef TuneAGC < adi.common.DebugAttribute & adi.common.RegisterReadWrite        
    properties (Nontunable, Hidden)
        AttackDelay = 1;
        PeakOverloadWaitTime = 10;
        AGCLockLevel = 10;
        DecStepSizeFullTableCase3 = 3;
        ADCLargeOverloadThresh = 58;
        ADCSmallOverloadThresh = 47;
        DecStepSizeFullTableCase2 = 3;
        DecStepSizeFullTableCase1 = 3;
        LargeLMTOverloadThresh = 35;
        SmallLMTOverloadThresh = 25;
        SettlingDelay = 3;
        EnergyLostThresh = 3;
        LowPowerThresh = 15;
        IncrementGainStep
        FAGCLockLevelGainIncreaseUpperLimit  = 7; 
        FAGCLPThreshIncrementTime = 3;
        DecPowMeasurementDuration = 16;
    end
    
    properties (Constant, Hidden, Access = private)
        % Register addresses in hexadecimal
        AttackDelay_Reg = '022';
        PeakOverloadWaitTime_Reg = '0FE';
        AGCLockLevel_Reg = '101';
        DecStepSizeFullTableCase3_Reg = '103'; 
        ADCSmallOverloadThresh_Reg = '104';
        ADCLargeOverloadThresh_Reg = '105';
        DecStepSizeFullTableCase2_Reg = '106'; 
        DecStepSizeFullTableCase1_Reg = '106';
        LargeLMTOverloadThresh_Reg = '108';
        SmallLMTOverloadThresh_Reg = '107';
        SettlingDelay_Reg = '111';
        EnergyLostThresh_Reg = '112';
        LowPowerThresh_Reg = '114';
        IncrementGainStep_Reg = '117';
        FAGCLockLevelGainIncreaseUpperLimit_Reg = '118';
        FAGCLPThreshIncrementTime_Reg = '11B';
        DecPowMeasurementDuration_Reg = '15C';
    
        % Register mask in binary
        AttackDelay_Mask = '11000000';
        PeakOverloadWaitTime_Mask = '11100000';
        AGCLockLevel_Mask = '10000000';
        DecStepSizeFullTableCase3_Mask = '11100011'; 
        DecStepSizeFullTableCase2_Mask = '10001111'; 
        DecStepSizeFullTableCase1_Mask = '11110000';
        LargeLMTOverloadThresh_Mask = '11000000';
        SmallLMTOverloadThresh_Mask = '11000000';
        SettlingDelay_Mask = '11100000';
        EnergyLostThresh_Mask = '11000000';
        LowPowerThresh_Mask = '10000000';
        IncrementGainStep_Mask = '00011111';
        FAGCLockLevelGainIncreaseUpperLimit_Mask = '11000000';
        DecPowMeasurementDuration_Mask = '11110000';
    
        % Bit-shifts to be applied
        DecStepSizeFullTableCase3_BitShift = 2; 
        DecStepSizeFullTableCase2_BitShift = 4; 
        IncrementGainStep_BitShift = 5;        
    end
    
    methods
        function set.AttackDelay(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',63}, ...
                '', 'AttackDelay');    
            obj.AttackDelay = value;
            if obj.ConnectedToDevice
                obj.setRegister(value, obj.AttackDelay_Reg, obj.AttackDelay_Mask);                
            end
        end
        function set.PeakOverloadWaitTime(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',31}, ...
                '', 'PeakOverloadWaitTime');    
            obj.PeakOverloadWaitTime = value;
            if obj.ConnectedToDevice
                obj.setRegister(value, obj.PeakOverloadWaitTime_Reg, obj.PeakOverloadWaitTime_Mask);                
            end
        end
        function set.AGCLockLevel(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',127}, ...
                '', 'AGCLockLevel');    
            obj.AGCLockLevel = value;
            if obj.ConnectedToDevice
                obj.setRegister(value, obj.AGCLockLevel_Reg, obj.AGCLockLevel_Mask);                
            end
        end 
        function set.DecStepSizeFullTableCase3(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',7}, ...
                '', 'DecStepSizeFullTableCase3');    
            obj.DecStepSizeFullTableCase3 = value;
            if obj.ConnectedToDevice
                obj.setRegister(value, obj.DecStepSizeFullTableCase3_Reg, obj.DecStepSizeFullTableCase3_Mask, obj.DecStepSizeFullTableCase3_BitShift);                
            end
        end
        function set.ADCLargeOverloadThresh(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',255}, ...
                '', 'ADCLargeOverloadThresh');    
            obj.ADCLargeOverloadThresh = value;
            if obj.ConnectedToDevice
                obj.setDebugAttributeLongLong('adi,gc-adc-large-overload-thresh',value);                    
            end
        end 
        function set.ADCSmallOverloadThresh(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',obj.ADCLargeOverloadThresh}, ...
                '', 'ADCSmallOverloadThresh');    
            obj.ADCSmallOverloadThresh = value;
            if obj.ConnectedToDevice
                obj.setDebugAttributeLongLong('adi,gc-adc-small-overload-thresh',value);                    
            end
        end
        function set.DecStepSizeFullTableCase2(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',7}, ...
                '', 'DecStepSizeFullTableCase2');    
            obj.DecStepSizeFullTableCase2 = value;
            if obj.ConnectedToDevice
                obj.setRegister(value, obj.DecStepSizeFullTableCase2_Reg, obj.DecStepSizeFullTableCase2_Mask, obj.DecStepSizeFullTableCase2_BitShift);                
            end
        end        
        function set.DecStepSizeFullTableCase1(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',15}, ...
                '', 'DecStepSizeFullTableCase1');    
            obj.DecStepSizeFullTableCase1 = value;
            if obj.ConnectedToDevice
                obj.setRegister(value, obj.DecStepSizeFullTableCase1_Reg, obj.DecStepSizeFullTableCase1_Mask);                
            end
        end        
        function set.LargeLMTOverloadThresh(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',63}, ...
                '', 'LargeLMTOverloadThresh');    
            obj.LargeLMTOverloadThresh = value;
            if obj.ConnectedToDevice
                obj.setRegister(value, obj.LargeLMTOverloadThresh_Reg, obj.LargeLMTOverloadThresh_Mask);                   
            end
        end 
        function set.SmallLMTOverloadThresh(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',obj.LargeLMTOverloadThresh}, ...
                '', 'SmallLMTOverloadThresh');    
            obj.SmallLMTOverloadThresh = value;
            if obj.ConnectedToDevice
                obj.setRegister(value, obj.SmallLMTOverloadThresh_Reg, obj.SmallLMTOverloadThresh_Mask);                   
            end
        end        
        function set.SettlingDelay(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',31}, ...
                '', 'SettlingDelay');    
            obj.SettlingDelay = value;
            if obj.ConnectedToDevice
                obj.setRegister(value, obj.SettlingDelay_Reg, obj.SettlingDelay_Mask);                   
            end
        end 
        function set.EnergyLostThresh(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',63}, ...
                '', 'SettlingDelay');    
            obj.EnergyLostThresh = value;
            if obj.ConnectedToDevice
                obj.setRegister(value, obj.EnergyLostThresh_Reg, obj.EnergyLostThresh_Mask);                   
            end
        end 
        function set.LowPowerThresh(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',63}, ...
                '', 'LowPowerThresh');    
            obj.LowPowerThresh = value;
            if obj.ConnectedToDevice
                obj.setDebugAttributeLongLong('adi,gc-low-power-thresh',value);                    
            end
        end 
        function set.IncrementGainStep(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',7}, ...
                '', 'IncrementGainStep');    
            obj.IncrementGainStep = value;
            if obj.ConnectedToDevice
                obj.setRegister(value, obj.IncrementGainStep_Reg, obj.IncrementGainStep_Mask, obj.IncrementGainStep_BitShift);                
            end
        end        
        function set.FAGCLockLevelGainIncreaseUpperLimit(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',63}, ...
                '', 'FAGCLockLevelGainIncreaseUpperLimit');    
            obj.FAGCLockLevelGainIncreaseUpperLimit = value;
            if obj.ConnectedToDevice
                obj.setDebugAttributeLongLong('adi,fagc-lock-level-gain-increase-upper-limit',value);              
            end
        end        
        function set.FAGCLPThreshIncrementTime(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',255}, ...
                '', 'FAGCLPThreshIncrementTime');    
            obj.FAGCLPThreshIncrementTime = value;
            if obj.ConnectedToDevice
                obj.setDebugAttributeLongLong('adi,fagc-lp-thresh-increment-time',value);              
            end
        end        
        function set.DecPowMeasurementDuration(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',15}, ...
                '', 'DecPowMeasurementDuration');    
            obj.DecPowMeasurementDuration = value;
            if obj.ConnectedToDevice
                obj.setRegister(value, obj.DecPowMeasurementDuration_Reg, obj.DecPowMeasurementDuration_Mask);                
            end
        end     
        function WriteToRegisters(obj)
            if obj.ConnectedToDevice
                obj.setRegister(obj.AttackDelay, obj.AttackDelay_Reg, obj.AttackDelay_Mask);  
                obj.setRegister(obj.PeakOverloadWaitTime, obj.PeakOverloadWaitTime_Reg, obj.PeakOverloadWaitTime_Mask);                
                obj.setRegister(obj.AGCLockLevel, obj.AGCLockLevel_Reg, obj.AGCLockLevel_Mask);                
                obj.setRegister(obj.DecStepSizeFullTableCase3, obj.DecStepSizeFullTableCase3_Reg, obj.DecStepSizeFullTableCase3_Mask, obj.DecStepSizeFullTableCase3_BitShift);                
                obj.setRegister(obj.DecStepSizeFullTableCase2, obj.DecStepSizeFullTableCase2_Reg, obj.DecStepSizeFullTableCase2_Mask, obj.DecStepSizeFullTableCase2_BitShift);                
                obj.setRegister(obj.DecStepSizeFullTableCase1, obj.DecStepSizeFullTableCase1_Reg, obj.DecStepSizeFullTableCase1_Mask);                
                obj.setRegister(obj.LargeLMTOverloadThresh, obj.LargeLMTOverloadThresh_Reg, obj.LargeLMTOverloadThresh_Mask);                   
                obj.setRegister(obj.SmallLMTOverloadThresh, obj.SmallLMTOverloadThresh_Reg, obj.SmallLMTOverloadThresh_Mask);                   
                obj.setRegister(obj.SettlingDelay, obj.SettlingDelay_Reg, obj.SettlingDelay_Mask);                   
                obj.setRegister(obj.EnergyLostThresh, obj.EnergyLostThresh_Reg, obj.EnergyLostThresh_Mask);    
                obj.setRegister(obj.IncrementGainStep, obj.IncrementGainStep_Reg, obj.IncrementGainStep_Mask, obj.IncrementGainStep_BitShift);     
                obj.setRegister(obj.DecPowMeasurementDuration, obj.DecPowMeasurementDuration_Reg, obj.DecPowMeasurementDuration_Mask);                
            end
        end
        function value = ReadFromRegister(obj, prop_name)
            if obj.ConnectedToDevice
                switch prop_name
                    case 'AttackDelay'
                        value = obj.getRegister(obj.AttackDelay_Reg, obj.AttackDelay_Mask);  
                    case 'PeakOverloadWaitTime'
                        value = obj.getRegister(obj.PeakOverloadWaitTime_Reg, obj.PeakOverloadWaitTime_Mask);                
                    case 'AGCLockLevel'
                        value = obj.getRegister(obj.AGCLockLevel_Reg, obj.AGCLockLevel_Mask);                
                    case 'DecStepSizeFullTableCase3'
                        value = obj.getRegister(obj.DecStepSizeFullTableCase3_Reg, obj.DecStepSizeFullTableCase3_Mask, obj.DecStepSizeFullTableCase3_BitShift);                
                    case 'ADCSmallOverloadThresh'
                        value = obj.getRegister(obj.ADCSmallOverloadThresh_Reg);                
                    case 'ADCLargeOverloadThresh'
                        value = obj.getRegister(obj.ADCLargeOverloadThresh_Reg);                
                    case 'DecStepSizeFullTableCase2'
                        value = obj.getRegister(obj.DecStepSizeFullTableCase2_Reg, obj.DecStepSizeFullTableCase2_Mask, obj.DecStepSizeFullTableCase2_BitShift);                
                    case 'DecStepSizeFullTableCase1'
                        value = obj.getRegister(obj.DecStepSizeFullTableCase1_Reg, obj.DecStepSizeFullTableCase1_Mask);                
                    case 'LargeLMTOverloadThresh'
                        value = obj.getRegister(obj.LargeLMTOverloadThresh_Reg, obj.LargeLMTOverloadThresh_Mask);                   
                    case 'SmallLMTOverloadThresh'
                        value = obj.getRegister(obj.SmallLMTOverloadThresh_Reg, obj.SmallLMTOverloadThresh_Mask);                   
                    case 'SettlingDelay'
                        value = obj.getRegister(obj.SettlingDelay_Reg, obj.SettlingDelay_Mask);                   
                    case 'EnergyLostThresh'
                        value = obj.getRegister(obj.EnergyLostThresh_Reg, obj.EnergyLostThresh_Mask);    
                    case 'LowPowerThresh'
                        value = obj.getRegister(obj.LowPowerThresh_Reg, obj.LowPowerThresh_Mask);    
                    case 'IncrementGainStep'
                        value = obj.getRegister(obj.IncrementGainStep_Reg, obj.IncrementGainStep_Mask, obj.IncrementGainStep_BitShift);     
                    case 'FAGCLockLevelGainIncreaseUpperLimit'
                        value = obj.getRegister(obj.FAGCLockLevelGainIncreaseUpperLimit_Reg, obj.FAGCLockLevelGainIncreaseUpperLimit_Mask);     
                    case 'FAGCLPThreshIncrementTime'
                        value = obj.getRegister(obj.FAGCLPThreshIncrementTime_Reg);  
                    case 'DecPowMeasurementDuration'
                        value = obj.getRegister(obj.DecPowMeasurementDuration_Reg, obj.DecPowMeasurementDuration_Mask);     
                    otherwise
                        error('Attempted to read unknown property %s\n', prop_name);
                end
            end            
        end                
    end
end