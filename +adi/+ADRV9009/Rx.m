classdef Rx < adi.ADRV9009.Base & adi.common.Rx & matlab.system.mixin.SampleTime
    % adi.ADRV9009.Rx Receive data from the ADRV9009 transceiver
    %   The adi.ADRV9009.Rx System object is a signal source that can receive
    %   complex data from the ADRV9009.
    %
    %   rx = adi.ADRV9009.Rx;
    %   rx = adi.ADRV9009.Rx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/ADRV9009.pdf">ADRV9009 Datasheet</a>    
    properties
        %GainControlMode Gain Control Mode
        %   specified as one of the following:
        %   'slow_attack' — For signals with slowly changing power levels
        %   'fast_attack' — For signals with rapidly changing power levels
        %   'manual' — For setting the gain manually with the Gain property
        %   'hybrid' — For configuring hybrid AGC mode
        GainControlMode = 'slow_attack';
        %GainChannel0 Gain Channel 0
        %   Channel 0 gain, specified as a scalar from -4 dB to 71 dB. The acceptable
        %   minimum and maximum gain setting depends on the center
        %   frequency.
        GainChannel0 = 10;
        %GainChannel1 Gain Channel 1
        %   Channel 1 gain, specified as a scalar from -4 dB to 71 dB. The acceptable
        %   minimum and maximum gain setting depends on the center
        %   frequency.
        GainChannel1 = 10;
    end
    
    properties (Nontunable, Logical) % MUST BE NONTUNABLE OR SIMULINK WARNS
        %EnableQuadratureTrackingChannel0 Enable Quadrature Tracking Channel 0
        %   Option to enable quadrature tracking, specified as true or
        %   false. When this property is true, IQ imbalance compensation is
        %   applied to the input signal.
        EnableQuadratureTrackingChannel0 = true;
        %EnableQuadratureTrackingChannel1 Enable Quadrature Tracking Channel 1
        %   Option to enable quadrature tracking, specified as true or
        %   false. When this property is true, IQ imbalance compensation is
        %   applied to the input signal.
        EnableQuadratureTrackingChannel1 = true;
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
        channel_names = {'voltage0_i','voltage0_q','voltage1_i','voltage1_q'};
    end
    
    properties (Nontunable, Hidden)
        devName = 'axi-adrv9009-rx-hpc';
    end
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            coder.allowpcode('plain');
            obj = obj@adi.ADRV9009.Base(varargin{:});
        end
        % Check GainControlMode
        function set.GainControlMode(obj, value)
            obj.GainControlMode = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeRAW(id,'gain_control_mode',value,false);
            end
        end
        % Check GainChannel0
        function set.GainChannel0(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', -4,'<=', 71}, ...
                '', 'Gain');
            assert(mod(value,1/4)==0, 'Gain must be a multiple of 0.25');
            obj.GainChannel0 = value;
            if obj.ConnectedToDevice && strcmp(obj.GainControlModeChannel0,'manual')
                id = 'voltage0';
                obj.setAttributeLongLong(id,'hardwaregain',value,false);
            end
        end
        % Check GainChannel1
        function set.GainChannel1(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', -4,'<=', 71}, ...
                '', 'Gain');
            assert(mod(value,1/4)==0, 'Gain must be a multiple of 0.25');
            obj.GainChannel1 = value;
            if obj.ConnectedToDevice && strcmp(obj.GainControlModeChannel1,'manual')
                id = 'voltage1';
                obj.setAttributeLongLong(id,'hardwaregain',value,false);
            end
        end
        % Check EnableQuadratureTrackingChannel0
        function set.EnableQuadratureTrackingChannel0(obj, value)
            obj.EnableQuadratureTrackingChannel0 = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeBool(id,'quadrature_tracking_en',value,false);
            end
        end
        % Check EnableQuadratureTrackingChannel1
        function set.EnableQuadratureTrackingChannel1(obj, value)
            obj.EnableQuadratureTrackingChannel1 = value;
            if obj.ConnectedToDevice
                id = 'voltage1';
                obj.setAttributeBool(id,'quadrature_tracking_en',value,false);
            end
        end
        
    end
       
    %% API Functions
    methods (Hidden, Access = protected)
        
        function sts = getSampleTimeImpl(obj)
            sts = createSampleTime(obj,'Type','Discrete',...
                'SampleTime',obj.SamplesPerFrame/obj.SamplingRate);
        end
        
        function setupInit(obj)
            % Write all attributes to device once connected through set
            % methods
            % Do writes directly to hardware without using set methods.
            % This is required sine Simulink support doesn't support
            % modification to nontunable variables at SetupImpl

            if obj.EnableCustomProfile
                writeProfileFile(obj);
            end
            
            obj.setAttributeRAW('voltage0','gain_control_mode',obj.GainControlMode,false);
            obj.setAttributeBool('voltage0','quadrature_tracking_en',obj.EnableQuadratureTrackingChannel0,false);
            obj.setAttributeBool('voltage1','quadrature_tracking_en',obj.EnableQuadratureTrackingChannel1,false);
            id = 'altvoltage0';
            obj.setAttributeLongLong(id,'frequency',obj.CenterFrequency ,true);

            if strcmp(obj.GainControlMode,'manual')
                obj.setAttributeLongLong('voltage0','hardwaregain',obj.GainChannel0,false);
                obj.setAttributeLongLong('voltage1','hardwaregain',obj.GainChannel1,false);
            end
        end
        
    end
    
end

