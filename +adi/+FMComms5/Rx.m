classdef Rx < adi.AD9361.Base & adi.common.Rx
    % adi.FMComms5.Rx Receive data from the FMComms5 development board
    %   The adi.FMComms5.Rx System object is a signal source that can receive
    %   complex data from the FMComms5.
    %
    %   rx = adi.FMComms5.Rx;
    %   rx = adi.FMComms5.Rx('uri','192.168.2.1');
    %
    %   <a href="https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/eval-ad-fmcomms5-ebz.html">FMComms5 Product Page</a>
    %
    %   See also adi.AD9361.Rx
    
    properties
        %GainControlModeChipA Gain Control Mode Chip A
        %   specified as one of the following:
        %   'slow_attack' — For signals with slowly changing power levels
        %   'fast_attack' — For signals with rapidly changing power levels
        %   'manual' — For setting the gain manually with the Gain property
        %   'hybrid' — For configuring hybrid AGC mode
        GainControlModeChipA = 'slow_attack';
        %GainControlModeChipB Gain Control Mode Chip B
        %   specified as one of the following:
        %   'slow_attack' — For signals with slowly changing power levels
        %   'fast_attack' — For signals with rapidly changing power levels
        %   'manual' — For setting the gain manually with the Gain property
        %   'hybrid' — For configuring hybrid AGC mode
        GainControlModeChipB = 'slow_attack';
        %GainChipA Gain Chip A
        %   Gain, specified as a scalar from -4 dB to 71 dB. The acceptable
        %   minimum and maximum gain setting depends on the center
        %   frequency.
        GainChipA = 10;
        %GainChipB Gain Chip B
        %   Gain, specified as a scalar from -4 dB to 71 dB. The acceptable
        %   minimum and maximum gain setting depends on the center
        %   frequency.
        GainChipB = 10;
    end
    
    properties (Logical)
        %EnableQuadratureTrackingChipA Enable Quadrature Tracking Chip A
        %   Option to enable quadrature tracking, specified as true or
        %   false. When this property is true, IQ imbalance compensation is
        %   applied to the input signal.
        EnableQuadratureTrackingChipA = true;
        %EnableQuadratureTrackingChipB Enable Quadrature Tracking Chip B
        %   Option to enable quadrature tracking, specified as true or
        %   false. When this property is true, IQ imbalance compensation is
        %   applied to the input signal.
        EnableQuadratureTrackingChipB = true;
        %EnableRFDCTrackingChipA Enable RFDC Tracking Chip A
        %   Option to enable RF DC tracking, specified as true or false.
        %   When this property is true, an RF DC blocking filter is applied
        %   to the input signal.
        EnableRFDCTrackingChipA = true;
        %EnableRFDCTrackingChipB Enable RFDC Tracking Chip B
        %   Option to enable RF DC tracking, specified as true or false.
        %   When this property is true, an RF DC blocking filter is applied
        %   to the input signal.
        EnableRFDCTrackingChipB = true;
        %EnableBasebandDCTrackingChipA Enable Baseband DC Tracking Chip A
        %   Option to enable baseband DC tracking, specified as true or
        %   false. When this property is true, a baseband DC blocking
        %   filter is applied to the input signal.
        EnableBasebandDCTrackingChipA = true;
        %EnableBasebandDCTrackingChipB Enable Baseband DC Tracking Chip B
        %   Option to enable baseband DC tracking, specified as true or
        %   false. When this property is true, a baseband DC blocking
        %   filter is applied to the input signal.
        EnableBasebandDCTrackingChipB = true;
    end
    
    properties(Constant, Hidden)
        GainControlModeSetChipA = matlab.system.StringSet({ ...
            'manual','fast_attack','slow_attack','hybrid'});
        GainControlModeSetChipB = matlab.system.StringSet({ ...
            'manual','fast_attack','slow_attack','hybrid'});
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties(Nontunable, Hidden)
        Type = 'Rx';
        channel_names = {'voltage0','voltage1','voltage2','voltage3',...
            'voltage4','voltage5','voltage6','voltage7'};
    end
    
    properties (Nontunable, Hidden)
        devName = 'cf-ad9361-A';
    end
    
    properties(Hidden)
        AD9361_B_Rx = adi.AD9361.Rx;
    end

    
    methods
        %% Constructor
        function obj = Rx(varargin)
            coder.allowpcode('plain');
            obj = obj@adi.AD9361.Base(varargin{:});
        end
        %% Destructor
        function delete(obj)
           release(obj.AD9361_B_Rx); 
        end
        % Check GainControlModeChipA
        function set.GainControlModeChipA(obj, value)
            obj.GainControlModeChipA = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeRAW(id,'gain_control_mode',value,false);
            end
        end
        % Check GainControlModeChipB
        function set.GainControlModeChipB(obj, value)
            obj.GainControlModeChipB = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeRAW(id,'gain_control_mode',value,false);
            end
        end
        % Check GainChipA
        function set.GainChipA(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', -4,'<=', 71}, ...
                '', 'Gain');
            assert(mod(value,1/4)==0, 'Gain must be a multiple of 0.25');
            obj.GainChipA = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeLongLong(id,'hardwaregain',value,false);
            end
        end
        % Check GainChipB
        function set.GainChipB(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', -4,'<=', 71}, ...
                '', 'Gain');
            assert(mod(value,1/4)==0, 'Gain must be a multiple of 0.25');
            obj.GainChipB = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeLongLong(id,'hardwaregain',value,false);
            end
        end
        % Check EnableQuadratureTrackingChipA
        function set.EnableQuadratureTrackingChipA(obj, value)
            obj.EnableQuadratureTrackingChipA = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeBool(id,'quadrature_tracking_en',value,false);
            end
        end
        % Check EnableQuadratureTrackingChipB
        function set.EnableQuadratureTrackingChipB(obj, value)
            obj.EnableQuadratureTrackingChipB = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeBool(id,'quadrature_tracking_en',value,false);
            end
        end
        % Check EnableRFDCTrackingChipA
        function set.EnableRFDCTrackingChipA(obj, value)
            obj.EnableRFDCTrackingChipA = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeBool(id,'rf_dc_offset_tracking_en',value,false);
            end
        end
        % Check EnableRFDCTrackingChipB
        function set.EnableRFDCTrackingChipB(obj, value)
            obj.EnableRFDCTrackingChipB = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeBool(id,'rf_dc_offset_tracking_en',value,false);
            end
        end
        % Check EnableRFDCTrackingChipA
        function set.EnableBasebandDCTrackingChipA(obj, value)
            obj.EnableBasebandDCTrackingChipA = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeBool(id,'bb_dc_offset_tracking_en',value,false);
            end
        end
        % Check EnableRFDCTrackingChipB
        function set.EnableBasebandDCTrackingChipB(obj, value)
            obj.EnableBasebandDCTrackingChipB = value;
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
            flagA = strcmpi(prop,'GainChipA') &&...
                ~strcmpi(obj.GainControlModeChipA, 'manual');
            flagB = strcmpi(prop,'GainChipB') &&...
                ~strcmpi(obj.GainControlModeChipB, 'manual');
            flag = flagA || flagB;
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
            % Set up secondary transceiver
            obj.AD9361_B_Rx.phyDevName = 'ad9361-phy-B';
            obj.AD9361_B_Rx.devName = 'cf-ad9361-B';
            obj.AD9361_B_Rx.channelCount = 0;
            obj.AD9361_B_Rx.uri = obj.uri;
            obj.AD9361_B_Rx.channel_names = [];
            
            % Write all attributes to device once connected through set
            % methods
            setupLibad9361(obj);
            % Do writes directly to hardware without using set methods.
            % This is required sine Simulink support doesn't support
            % modification to nontunable variables at SetupImpl
            %% Chip A
            obj.setAttributeRAW('voltage0','gain_control_mode',obj.GainControlModeChipA,false);
            obj.setAttributeBool('voltage0','quadrature_tracking_en',obj.EnableQuadratureTrackingChipA,false);
            obj.setAttributeBool('voltage0','rf_dc_offset_tracking_en',obj.EnableRFDCTrackingChipA,false);
            obj.setAttributeBool('voltage0','bb_dc_offset_tracking_en',obj.EnableBasebandDCTrackingChipA,false);
            id = sprintf('altvoltage%d',strcmp(obj.Type,'Tx'));
            obj.setAttributeLongLong(id,'frequency',obj.CenterFrequency ,true);
            if libisloaded('libad9361')
                calllib('libad9361','ad9361_set_bb_rate',obj.iioDevPHY,int32(obj.SamplingRate));
            else
                obj.setAttributeLongLong('voltage0','sampling_frequency',obj.SamplingRate,true);
            end
            obj.setAttributeLongLong('voltage0','hardwaregain',obj.GainChipA,false);
            obj.setAttributeLongLong('voltage0','rf_bandwidth',obj.RFBandwidth ,strcmp(obj.Type,'Tx'));
            %% Chip B
            obj.AD9361_B_Rx();
            
            obj.AD9361_B_Rx.setAttributeRAW('voltage0','gain_control_mode',obj.GainControlModeChipB,false);
            obj.AD9361_B_Rx.setAttributeBool('voltage0','quadrature_tracking_en',obj.EnableQuadratureTrackingChipB,false);
            obj.AD9361_B_Rx.setAttributeBool('voltage0','rf_dc_offset_tracking_en',obj.EnableRFDCTrackingChipB,false);
            obj.AD9361_B_Rx.setAttributeBool('voltage0','bb_dc_offset_tracking_en',obj.EnableBasebandDCTrackingChipB,false);
            id = sprintf('altvoltage%d',strcmp(obj.Type,'Tx'));
            obj.AD9361_B_Rx.setAttributeLongLong(id,'frequency',obj.CenterFrequency ,true);
            if libisloaded('libad9361')
                calllib('libad9361','ad9361_set_bb_rate',obj.AD9361_B_Rx.iioDevPHY,int32(obj.SamplingRate));
            else
                obj.AD9361_B_Rx.setAttributeLongLong('voltage0','sampling_frequency',obj.SamplingRate,true);
            end
            obj.AD9361_B_Rx.setAttributeLongLong('voltage0','hardwaregain',obj.GainChipB,false);
            obj.AD9361_B_Rx.setAttributeLongLong('voltage0','rf_bandwidth',obj.RFBandwidth ,strcmp(obj.Type,'Tx'));

        end
        
    end
    
end

