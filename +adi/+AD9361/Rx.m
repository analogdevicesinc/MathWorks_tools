classdef Rx < adi.AD9361.Base & adi.common.Rx
    % adi.AD9361.Rx Receive data from the AD9361 transceiver
    %   The adi.AD9361.Rx System object is a signal source that can receive
    %   complex data from the AD9361.
    %
    %   rx = adi.AD9361.Rx;
    %   rx = adi.AD9361.Rx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9361.pdf">AD9361 Datasheet</a>
    %
    %   See also adi.FMComms2.Rx, adi.FMComms3.Rx, adi.FMComms5.Rx
    
    properties
        %GainControlMode Gain Control Mode
        %   specified as one of the following:
        %   'slow_attack' — For signals with slowly changing power levels
        %   'fast_attack' — For signals with rapidly changing power levels
        %   'manual' — For setting the gain manually with the Gain property
        %   'hybrid' — For configuring hybrid AGC mode
        GainControlMode = 'slow_attack';
        %Gain Gain
        %   Gain, specified as a scalar from -4 dB to 71 dB. The acceptable
        %   minimum and maximum gain setting depends on the center
        %   frequency.
        Gain = 10;
    end
    
    properties (Logical)
        %EnableQuadratureTracking Enable Quadrature Tracking
        %   Option to enable quadrature tracking, specified as true or
        %   false. When this property is true, IQ imbalance compensation is
        %   applied to the input signal.
        EnableQuadratureTracking = true;
        %EnableRFDCTracking Enable RFDC Tracking
        %   Option to enable RF DC tracking, specified as true or false.
        %   When this property is true, an RF DC blocking filter is applied
        %   to the input signal.
        EnableRFDCTracking = true;
        %EnableBasebandDCTracking Enable Baseband DC Tracking
        %   Option to enable baseband DC tracking, specified as true or
        %   false. When this property is true, a baseband DC blocking
        %   filter is applied to the input signal.
        EnableBasebandDCTracking = true;
    end
    
    properties(Constant, Hidden)
        GainControlModeSet = matlab.system.StringSet({ ...
            'manual','fast_attack','slow_attack','hybrid'});
    end

    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
        channel_names = {'voltage0','voltage1','voltage2','voltage3'};
    end
    
    properties (Nontunable, Hidden)
        devName = 'cf-ad9361-lpc';
    end
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            coder.allowpcode('plain');
            obj = obj@adi.AD9361.Base(varargin{:});
        end
        % Check GainControlMode
        function set.GainControlMode(obj, value)
            obj.GainControlMode = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeRAW(id,'gain_control_mode',value,false);
            end
        end
        % Check Gain
        function set.Gain(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', -4,'<=', 71}, ...
                '', 'Gain');
            assert(mod(value,1/4)==0, 'Gain must be a multiple of 0.25');
            obj.Gain = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeLongLong(id,'hardwaregain',value,false);
            end
        end
        % Check EnableQuadratureTracking
        function set.EnableQuadratureTracking(obj, value)
            obj.EnableQuadratureTracking = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeBool(id,'quadrature_tracking_en',value,false);
            end
        end
        % Check EnableRFDCTracking
        function set.EnableRFDCTracking(obj, value)
            obj.EnableRFDCTracking = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeBool(id,'rf_dc_offset_tracking_en',value,false);
            end
        end
        % Check EnableRFDCTracking
        function set.EnableBasebandDCTracking(obj, value)
            obj.EnableBasebandDCTracking = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeBool(id,'bb_dc_offset_tracking_en',value,false);
            end
        end
    end
    
    methods (Access=protected)
        % Only show Gain when GainControlMode set to
        % 'manual'
        function flag = isInactivePropertyImpl(obj, prop)
            flag = strcmpi(prop,'Gain') &&...
                ~strcmpi(obj.GainControlMode, 'manual');
            
        end
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        function numOut = getNumOutputsImpl(obj)
            numOut = obj.channelCount/2 + 1; % +1 for valid
        end
       
        function setupInit(obj)
            % Write all attributes to device once connected through set
            % methods
            obj.GainControlMode = obj.GainControlMode;
            obj.EnableQuadratureTracking = obj.EnableQuadratureTracking;
            obj.EnableRFDCTracking = obj.EnableRFDCTracking;
            obj.EnableBasebandDCTracking = obj.EnableBasebandDCTracking;
            obj.CenterFrequency = obj.CenterFrequency;
            obj.SamplingRate = obj.SamplingRate;
            obj.Gain = obj.Gain;
            obj.RFBandwidth = obj.RFBandwidth;
        end
        
    end
    
end

