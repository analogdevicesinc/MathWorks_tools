classdef (Abstract) ADC < matlab.System
    % ADC: Common shared attributes across ADC designs  
    properties
        %CalibrationBias Calibration Bias
        CalibrationBias = 0;
        %CalibrationPhase Calibration Phase
        CalibrationPhase = 0;
        %CalibrationScale Calibration Scale
        CalibrationScale = 1;
    end
    
    methods
        % Check CalibrationBias
        function set.CalibrationBias(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty'}, ...
                '', 'CalibrationBias');
            obj.CalibrationBias = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeLongLong(id,'calibbias',value,false);
            end
        end
        % Check CalibrationPhase
        function set.CalibrationPhase(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty'}, ...
                '', 'CalibrationPhase');
            obj.CalibrationPhase = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeRAW(id,'calibphase',num2str(value),false);
            end
        end
        % Check CalibrationScale
        function set.CalibrationScale(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty'}, ...
                '', 'CalibrationScale');
            obj.CalibrationScale = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeRAW(id,'calibscale',num2str(value),false);
            end
        end
    end
    
end

