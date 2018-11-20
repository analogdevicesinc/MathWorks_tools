classdef Rx < adi.AD9361.Base & adi.common.Rx & matlab.system.mixin.SampleTime
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
        %CenterFrequency Center Frequency
        %   RF center frequency, specified in Hz as a scalar. The
        %   default is 2.4e9.  This property is tunable.
        CenterFrequency = 2.4e9;
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar 
        %   from 65105 to 61.44e6 samples per second.
        SamplingRate = 3e6;
        %RFBandwidth RF Bandwidth
        %   RF Bandwidth of front-end analog filter in Hz, specified as a
        %   scalar from 200 kHz to 56 MHz.
        RFBandwidth = 3e6;
    end
    
    properties
        %GainControlModeChannel0 Gain Control Mode Channel 0
        %   specified as one of the following:
        %   'slow_attack' — For signals with slowly changing power levels
        %   'fast_attack' — For signals with rapidly changing power levels
        %   'manual' — For setting the gain manually with the Gain property
        %   'hybrid' — For configuring hybrid AGC mode
        GainControlModeChannel0 = 'slow_attack';
        %GainChannel0 Gain Channel 0
        %   Channel 0 gain, specified as a scalar from -4 dB to 71 dB. The acceptable
        %   minimum and maximum gain setting depends on the center
        %   frequency.
        GainChannel0 = 10;
        %GainControlModeChannel1 Gain Control Mode Channel 1
        %   specified as one of the following:
        %   'slow_attack' — For signals with slowly changing power levels
        %   'fast_attack' — For signals with rapidly changing power levels
        %   'manual' — For setting the gain manually with the Gain property
        %   'hybrid' — For configuring hybrid AGC mode
        GainControlModeChannel1 = 'slow_attack';
        %GainChannel1 Gain Channel 1
        %   Channel 1 gain, specified as a scalar from -4 dB to 71 dB. The acceptable
        %   minimum and maximum gain setting depends on the center
        %   frequency.
        GainChannel1 = 10;
    end
    
    properties (Nontunable, Logical) % MUST BE NONTUNABLE OR SIMULINK WARNS
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
        GainControlModeChannel0Set = matlab.system.StringSet({ ...
            'manual','fast_attack','slow_attack','hybrid'});
        GainControlModeChannel1Set = matlab.system.StringSet({ ...
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
        % Check GainControlModeChannel0
        function set.GainControlModeChannel0(obj, value)
            obj.GainControlModeChannel0 = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeRAW(id,'gain_control_mode',value,false);
            end
        end
        % Check GainControlModeChannel1
        function set.GainControlModeChannel1(obj, value)
            obj.GainControlModeChannel1 = value;
            if obj.ConnectedToDevice
                id = 'voltage1';
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
            if obj.ConnectedToDevice && strcmp(obj.GainControlModeChannel0,'manual') %#ok<MCSUP>
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
            if obj.ConnectedToDevice && strcmp(obj.GainControlModeChannel1,'manual') %#ok<MCSUP>
                id = 'voltage1';
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
        % Check CenterFrequency
        function set.CenterFrequency(obj, value)
            if isa(obj,'adi.AD9363.Rx')
                validateattributes( value, { 'double','single' }, ...
                    { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',325e6,'<=',3.8e9}, ...
                    '', 'CenterFrequency');
            else
                validateattributes( value, { 'double','single' }, ...
                    { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',70e6,'<=',6e9}, ...
                    '', 'CenterFrequency');
            end
            obj.CenterFrequency = value;
            if obj.ConnectedToDevice
                id = sprintf('altvoltage%d',strcmp(obj.Type,'Tx'));
                obj.setAttributeLongLong(id,'frequency',value,true,4);
            end
        end
        % Check RFBandwidth
        function set.RFBandwidth(obj, value)
            if isa(obj,'adi.AD9363.Rx')
                validateattributes( value, { 'double','single' }, ...
                    { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',200e3,'<=',20e6}, ...
                    '', 'RFBandwidth');
            else
                validateattributes( value, { 'double','single' }, ...
                    { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',200e3,'<=',56e6}, ...
                    '', 'RFBandwidth');
            end
            obj.RFBandwidth = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeLongLong(id,'rf_bandwidth',value,strcmp(obj.Type,'Tx'),30);
            end
        end
        % Check SampleRate
        function set.SamplingRate(obj, value)
            if isa(obj,'adi.AD9363.Rx')
                validateattributes( value, { 'double','single' }, ...
                    { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',520833,'<=',20e6}, ...
                    '', 'SamplesPerFrame');
            else
                validateattributes( value, { 'double','single' }, ...
                    { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',520833,'<=',61.44e6}, ...
                    '', 'SamplesPerFrame');
            end
            
            obj.SamplingRate = value;
            if obj.ConnectedToDevice
                if libisloaded('libad9361')
                    calllib('libad9361','ad9361_set_bb_rate',obj.iioDevPHY,int32(value));
                else
                    id = 'voltage0';
                    obj.setAttributeLongLong(id,'sampling_frequency',value,true,4);
                end
            end
        end
    end
    
    methods (Access=protected)
        % Hide unused parameters when in specific modes
        function flag = isInactivePropertyImpl(obj, prop)
            % Call the superclass method
            flag = isInactivePropertyImpl@adi.common.RxTx(obj,prop);
        end
        
        function varargout = getOutputNamesImpl(obj)
            % Return output port names for System block
            numOut = obj.channelCount/2 + 1; % +1 for valid
            varargout = cell(1,numOut);
            for k=1:numOut-1
                varargout{k} = ['chan',num2str(k)];
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
        
        function sts = getSampleTimeImpl(obj)
            sts = createSampleTime(obj,'Type','Discrete',...
                'SampleTime',obj.SamplesPerFrame/obj.SamplingRate);
        end
        
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
            obj.setAttributeRAW('voltage0','gain_control_mode',obj.GainControlModeChannel0,false);
            if obj.channelCount>2
                obj.setAttributeRAW('voltage1','gain_control_mode',obj.GainControlModeChannel1,false);
            end
            obj.setAttributeBool('voltage0','quadrature_tracking_en',obj.EnableQuadratureTracking,false);
            obj.setAttributeBool('voltage0','rf_dc_offset_tracking_en',obj.EnableRFDCTracking,false);
            obj.setAttributeBool('voltage0','bb_dc_offset_tracking_en',obj.EnableBasebandDCTracking,false);
            id = sprintf('altvoltage%d',strcmp(obj.Type,'Tx'));
            obj.setAttributeLongLong(id,'frequency',obj.CenterFrequency ,true,4);
            if libisloaded('libad9361')
                calllib('libad9361','ad9361_set_bb_rate',obj.iioDevPHY,int32(obj.SamplingRate));
            else
                obj.setAttributeLongLong('voltage0','sampling_frequency',obj.SamplingRate,true,4);
            end
            if strcmp(obj.GainControlModeChannel0,'manual')
                obj.setAttributeLongLong('voltage0','hardwaregain',obj.GainChannel0,false);
            end
            if strcmp(obj.GainControlModeChannel1,'manual') && (obj.channelCount>2)
                obj.setAttributeLongLong('voltage1','hardwaregain',obj.GainChannel1,false);
            end
            obj.setAttributeLongLong('voltage0','rf_bandwidth',obj.RFBandwidth ,strcmp(obj.Type,'Tx'));
        end
        
    end
    
end

