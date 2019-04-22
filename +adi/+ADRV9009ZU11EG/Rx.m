classdef Rx < adi.ADRV9009ZU11EG.Base & adi.common.Rx & matlab.system.mixin.SampleTime
    % adi.ADRV9009ZU11EG.Rx Receive data from the ADRV9009ZU11EG SOM
    %   The adi.ADRV9009ZU11EG.Rx System object is a signal source that can receive
    %   complex data from the ADRV9009ZU11EG.
    %
    %   rx = adi.ADRV9009ZU11EG.Rx;
    %   rx = adi.ADRV9009ZU11EG.Rx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/ADRV9009.pdf">ADRV9009 Datasheet</a>    
    properties
        %GainControlModeChipA Gain Control Mode
        %   specified as one of the following:
        %   'slow_attack' — For signals with slowly changing power levels
        %   'manual' — For setting the gain manually with the Gain property
        GainControlModeChipA = 'slow_attack';
        %GainControlModeChipB Gain Control Mode
        %   specified as one of the following:
        %   'slow_attack' — For signals with slowly changing power levels
        %   'manual' — For setting the gain manually with the Gain property
        GainControlModeChipB = 'slow_attack';
        %GainChannel0 Gain Channel 0 Chip A
        %   Channel 0 gain, specified as a scalar from -4 dB to 71 dB. The acceptable
        %   minimum and maximum gain setting depends on the center
        %   frequency.
        GainChannel0 = 10;
        %GainChannel1 Gain Channel 1 Chip A
        %   Channel 1 gain, specified as a scalar from -4 dB to 71 dB. The acceptable
        %   minimum and maximum gain setting depends on the center
        %   frequency.
        GainChannel1 = 10;
        %GainChannel2 Gain Channel 0 Chip B
        %   Channel 0 gain, specified as a scalar from -4 dB to 71 dB. The acceptable
        %   minimum and maximum gain setting depends on the center
        %   frequency.
        GainChannel2 = 10;
        %GainChannel3 Gain Channel 1 Chip B
        %   Channel 1 gain, specified as a scalar from -4 dB to 71 dB. The acceptable
        %   minimum and maximum gain setting depends on the center
        %   frequency.
        GainChannel3 = 10;
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
        %EnableQuadratureTrackingChannel2 Enable Quadrature Tracking Channel 2
        %   Option to enable quadrature tracking, specified as true or
        %   false. When this property is true, IQ imbalance compensation is
        %   applied to the input signal.
        EnableQuadratureTrackingChannel2 = true;
        %EnableQuadratureTrackingChannel3 Enable Quadrature Tracking Channel 3
        %   Option to enable quadrature tracking, specified as true or
        %   false. When this property is true, IQ imbalance compensation is
        %   applied to the input signal.
        EnableQuadratureTrackingChannel3 = true;
    end
    
    properties(Constant, Hidden)
        GainControlModeChipASet = matlab.system.StringSet({ ...
            'manual','slow_attack'});
        GainControlModeChipBSet = matlab.system.StringSet({ ...
            'manual','slow_attack'});
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
        channel_names = {...
            'voltage0_i','voltage0_q',...
            'voltage1_i','voltage1_q',...
            'voltage2_i','voltage2_q',...
            'voltage3_i','voltage3_q'};
    end
    
    properties (Nontunable, Hidden)
        devName = 'axi-adrv9009-rx-hpc';
    end
    
    properties(Hidden)
        ADRV9009_B_Rx = adi.ADRV9009.Rx(...
            'phyDevName','adrv9009-phy-b',...
            'channelCount',0);
    end
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            coder.allowpcode('plain');
            obj = obj@adi.ADRV9009ZU11EG.Base(varargin{:});
        end
        %% Destructor
        function delete(obj)
           release(obj.ADRV9009_B_Rx); 
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
                obj.ADRV9009_B_Rx.setAttributeRAW(id,'gain_control_mode',value,false); %#ok<MCSUP>
            end
        end
        % Check GainChannel0
        function set.GainChannel0(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', -4,'<=', 71}, ...
                '', 'Gain');
            assert(mod(value,1/4)==0, 'Gain must be a multiple of 0.25');
            obj.GainChannel0 = value;
            if obj.ConnectedToDevice && strcmp(obj.GainControlModeChipA,'manual') %#ok<MCSUP>
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
            if obj.ConnectedToDevice && strcmp(obj.GainControlModeChipA,'manual') %#ok<MCSUP>
                id = 'voltage1';
                obj.setAttributeLongLong(id,'hardwaregain',value,false);
            end
        end
        % Check GainChannel0ChipB
        function set.GainChannel2(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', -4,'<=', 71}, ...
                '', 'Gain');
            assert(mod(value,1/4)==0, 'Gain must be a multiple of 0.25');
            obj.GainChannel2 = value;
            if obj.ConnectedToDevice && strcmp(obj.GainControlModeChipB,'manual') %#ok<MCSUP>
                id = 'voltage0';
                obj.ADRV9009_B_Rx.setAttributeLongLong(id,'hardwaregain',value,false); %#ok<MCSUP>
            end
        end
        % Check GainChannel1ChipB
        function set.GainChannel3(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', -4,'<=', 71}, ...
                '', 'Gain');
            assert(mod(value,1/4)==0, 'Gain must be a multiple of 0.25');
            obj.GainChannel3 = value;
            if obj.ConnectedToDevice && strcmp(obj.GainControlModeChipB,'manual') %#ok<MCSUP>
                id = 'voltage1';
                obj.ADRV9009_B_Rx.setAttributeLongLong(id,'hardwaregain',value,false); %#ok<MCSUP>
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
            % Do writes directly to hardware without using set methods.
            % This is required sine Simulink support doesn't support
            % modification to nontunable variables at SetupImpl
            
            obj.ADRV9009_B_Rx.uri = obj.uri;
            obj.ADRV9009_B_Rx();
            
            obj.setAttributeRAW('voltage0','gain_control_mode',obj.GainControlModeChipA,false);
            obj.ADRV9009_B_Rx.setAttributeRAW('voltage0','gain_control_mode',obj.GainControlModeChipB,false);
            obj.setAttributeBool('voltage0','quadrature_tracking_en',obj.EnableQuadratureTrackingChannel0,false);
            obj.setAttributeBool('voltage1','quadrature_tracking_en',obj.EnableQuadratureTrackingChannel1,false);
            obj.setAttributeBool('voltage2','quadrature_tracking_en',obj.EnableQuadratureTrackingChannel2,false);
            obj.setAttributeBool('voltage3','quadrature_tracking_en',obj.EnableQuadratureTrackingChannel3,false);
            id = 'altvoltage0';
            obj.setAttributeLongLong(id,'frequency',obj.CenterFrequencyChipA ,true);
            obj.ADRV9009_B_Rx.setAttributeLongLong(id,'frequency',obj.CenterFrequencyChipB ,true);

            if strcmp(obj.GainControlModeChipA,'manual')
                obj.setAttributeLongLong('voltage0','hardwaregain',obj.GainChannel0,false);
                obj.setAttributeLongLong('voltage1','hardwaregain',obj.GainChannel1,false);
            end
            if strcmp(obj.GainControlModeChipB,'manual')
                obj.ADRV9009_B_Rx.setAttributeLongLong('voltage0','hardwaregain',obj.GainChannel2,false);
                obj.ADRV9009_B_Rx.setAttributeLongLong('voltage1','hardwaregain',obj.GainChannel3,false);
            end
        end
        
    end
    
end

