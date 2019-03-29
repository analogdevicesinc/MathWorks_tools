classdef Rx < adi.common.Sensor & matlabshared.libiio.base & ...
        matlab.system.mixin.CustomIcon
    %RX ADIS16460 Inertial Measurement Unit
    %   The adi.ADIS16460.Rx System object is a signal source that can
    %   collect IMU data from the ADIS16460.
    %
    %   rx = adi.ADIS16460.Rx;
    %   rx = adi.ADIS16460.Rx('uri','192.168.2.1');
    %
    %   [accel,vel,temp] = rx() produces three outputs where accel is a Nx3
    %   matrix containing acceleration data for x, y, and z respectively
    %   in m/s where N is SamplesPerFrame. vel is the same as accel except 
    %   it contains velocity data for x, y, and z in m/s. temp is the
    %   current temperature of the IMU in degree celsius.
    %
    %   <a href="https://www.analog.com/media/en/technical-documentation/data-sheets/ADIS16460.pdf">ADIS16460 Datasheet</a>    
    properties (Nontunable)
        %SamplesPerFrame Samples Per Frame
        %   Number of samples per frame, specified as an even positive
        %   integer from 2 to 16,777,216. Using values less than 3660 can
        %   yield poor performance.
        SamplesPerFrame = 16;
    end
    properties (Nontunable,  Logical)
        %EnableAccelerationOutput Enable Acceleration Output
        %   Boolean when set outputs acceleration data
        EnableAccelerationOutput = true;
        %EnableVelocityOutput Enable Velocity Output
        %   Boolean when set outputs velocity data
        EnableVelocityOutput = true;
        %EnableTemperatureOutput Enable Temperature Output
        %   Boolean when set outputs temperature data
        EnableTemperatureOutput = true;
    end
    
    properties(Nontunable, Hidden)
        channelCount = 0;
    end
    
    properties(Nontunable, Hidden)
        SamplingFrequency = 2048;
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties(Nontunable, Hidden)
        Timeout = Inf;
        kernelBuffersCount = 2;
         %  NOT USED
        dataTypeStr = 'int32';
        phyDevName = 'adis16460';
        iioDevPHY
        devName = 'adis16460';
    end
    
    properties(Nontunable, Hidden, Constant)
        SensorAttributeNames = {'anglvel_x','anglvel_y','anglvel_z',...
            'accel_x','accel_y','accel_z','temp0'};
        SensorAttributeTypes = {'Double','Double','Double',...
            'Double','Double','Double','Double'};
        Type = 'Rx';
    end
    properties (Hidden)
        % Filled in at runtime
        SensorAttributeScales = zeros(7,1);
    end
    
    methods
        function obj = Rx(varargin)
            coder.allowpcode('plain');
            obj = obj@matlabshared.libiio.base(varargin{:});
        end
        
        % Check SamplingFrequency
        function set.SamplingFrequency(obj, value)
            obj.GainControlMode = value;
            if obj.ConnectedToDevice
                obj.setDeviceAttributeLongLong('sampling_frequency',value,false);
            end
        end
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        function varargout = stepImpl(obj)
            % Get the data
            [...
                anglvel_x,anglvel_y,anglvel_z,...
                accel_x,accel_y,accel_z,...
                temp...
                ] = stepImpl@adi.common.Sensor(obj);
            angvel = [anglvel_x,anglvel_y,anglvel_z];
            accel = [accel_x,accel_y,accel_z];
            
            outs = obj.EnableAccelerationOutput + ...
                obj.EnableVelocityOutput + ...
                obj.EnableTemperatureOutput;
            indx = 0;
            varargout = cell(outs,1);
            if obj.EnableAccelerationOutput
                indx = indx + 1;
                varargout{indx} = accel;
            end
            if obj.EnableVelocityOutput
                indx = indx + 1;
                varargout{indx} = angvel;
            end
            if obj.EnableTemperatureOutput
                indx = indx + 1;
                varargout{indx} = temp;
            end
        end
        
        function icon = getIconImpl(obj)
            icon = sprintf(['ADIS16460 ',obj.Type]);
        end
        
        function sts = getSampleTimeImpl(obj)
            sts = createSampleTime(obj,'Type','Discrete',...
                'SampleTime',obj.SamplesPerFrame/obj.SamplingRate);
        end
        
        function numOut = getNumOutputsImpl(obj)
            numOut = obj.EnableAccelerationOutput + ...
                obj.EnableVelocityOutput + ...
                obj.EnableTemperatureOutput;
        end
        
        function setupInit(obj)
            obj.SensorAttributeScales = CollectScales(obj);
        end
        
    end
end

