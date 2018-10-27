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
        
        function varargout = getOutputNamesImpl(obj)
            % Return output port names for System block
            numOut = obj.channelCount/2 + 1; % +1 for valid
            varargout = cell(1,numOut);
            for k=1:numOut-1
                varargout{k} = ['out',num2str(k)];
            end
            varargout{numOut} = 'valid';
        end
        
        function varargout = getOutputSizeImpl(obj)
            % Return size for each output port
            numOut = obj.channelCount/2 + 1; % +1 for valid
            varargout = cell(1,numOut);
            for k=1:numOut-1
                varargout{k} = [obj.SamplesPerFrame,1];
            end
            varargout{numOut} = [1,1];
        end
        
        function varargout = getOutputDataTypeImpl(obj)
            % Return data type for each output port
            numOut = obj.channelCount/2 + 1; % +1 for valid
            varargout = cell(1,numOut);
            for k=1:numOut-1
                varargout{k} = "int16";
            end
            varargout{numOut} = "logical";
        end
        
        function varargout = isOutputComplexImpl(obj)
            % Return true for each output port with complex data
            out = true;
            numOut = obj.channelCount/2 + 1; % +1 for valid
            varargout = cell(1,numOut);
            for k=1:numOut-1
                varargout{k} = true;
            end
            varargout{numOut} = false;
        end
        
        function varargout = isOutputFixedSizeImpl(obj)
            % Return true for each output port with fixed size
            numOut = obj.channelCount/2 + 1; % +1 for valid
            varargout = cell(1,numOut);
            for k=1:numOut
                varargout{k} = true;
            end
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
            setupLibad9361(obj);
            % Do writes directly to hardware without using set methods.
            % This is required sine Simulink support doesn't support
            % modification to nontunable variables at SetupImpl
            obj.setAttributeRAW('voltage0','gain_control_mode',obj.GainControlMode,false);
            obj.setAttributeBool('voltage0','quadrature_tracking_en',obj.EnableQuadratureTracking,false);
            obj.setAttributeBool('voltage0','rf_dc_offset_tracking_en',obj.EnableRFDCTracking,false);
            obj.setAttributeBool('voltage0','bb_dc_offset_tracking_en',obj.EnableBasebandDCTracking,false);
            id = sprintf('altvoltage%d',strcmp(obj.Type,'Tx'));
            obj.setAttributeLongLong(id,'frequency',obj.CenterFrequency ,true);
            if libisloaded('libad9361')
                calllib('libad9361','ad9361_set_bb_rate',obj.iioDevPHY,int32(obj.SamplingRate));
            else
                obj.setAttributeLongLong('voltage0','sampling_frequency',obj.SamplingRate,true);
            end
            obj.setAttributeLongLong('voltage0','hardwaregain',obj.Gain,false);
            obj.setAttributeLongLong('voltage0','rf_bandwidth',obj.RFBandwidth ,strcmp(obj.Type,'Tx'));
        end
        
    end
    
end

