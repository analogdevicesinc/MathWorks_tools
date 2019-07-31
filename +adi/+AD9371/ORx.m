classdef ORx < adi.AD9371.Base & adi.common.Rx
    % adi.AD9371.ORx Receive data from the AD9371 transceiver observation receiver
    %   The adi.AD9371.ORx System object is a signal source that can receive
    %   complex data from the AD9371. This object is used for both
    %   observation and sniffer paths since they share ADCs within the
    %   transceiver itself.
    %
    %   rx = adi.AD9371.ORx;
    %   rx = adi.AD9371.ORx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9371.pdf">AD9371 Datasheet</a>    
    properties
        %GainControlMode Gain Control Mode
        %   specified as one of the following:
        %   'automatic' — For signals with changing power levels
        %   'manual' — For setting the gain manually with the Gain property
        %   'hybrid' — For configuring hybrid AGC mode
        GainControlMode = 'automatic';
        %Gain Gain
        %   Rx gain, specified as a scalar from 0 dB to 52 dB. The acceptable
        %   minimum and maximum gain setting depends on the center
        %   frequency.
        Gain = 10;
    end
    
    properties (Nontunable)
        %DigitalLoopbackMode Digital Loopback Mode
        %   Option to set digital loopback mode, specified as 0 or 1.
        %   Allows digital loopback of TX data into the ORX path.
        %    Value   |    Mode
        %   ---------------------------
        %      0     |   Disable
        %      1     |   Enable
        LoopbackMode = 0;        
    end
    
    properties (Nontunable, Logical) % MUST BE NONTUNABLE OR SIMULINK WARNS
        %EnableQuadratureTracking Enable Quadrature Tracking
        %   Option to enable quadrature tracking, specified as true or
        %   false. When this property is true, IQ imbalance compensation is
        %   applied to the input signal.
        EnableQuadratureTracking = true;
    end
    
    properties
        %RFPortSelect RF Port Select
        %    'OFF' - SnRx path is disabled
        %    'ORX1_TX_LO' – SnRx operates in observation mode on ORx1 with
        %       Tx LO synthesizer
        %    'ORX2_TX_LO' – SnRx operates in observation mode on ORx2 with
        %       Tx LO synthesizer
        %    'INTERNALCALS' – enables scheduled Tx calibrations while using
        %       SnRx path. The enableTrackingCals function needs to be called
        %       in RADIO_OFF state. It sets the calibration mask, which the
        %       scheduler will later use to schedule the desired calibrations.
        %       This command is issued in RADIO_OFF. Once the AD9371 moves to
        %       RADIO_ON state, the internal scheduler will use the enabled
        %       calibration mask to schedule calibrations whenever possible,
        %       based on the state of the transceiver. The Tx calibrations
        %       will not be scheduled until INTERNALCALS is selected and the
        %       Tx calibrations are enabled in the cal mask.
        %    'OBS_SNIFFER' – SnRx operates in sniffer mode with latest
        %       selected Sniffer Input – for hardware pin control operation.
        %       In pin mode, the GPIO pins designated for ORX_MODE would
        %       select SNIFFER mode. Then MYKONOS_setSnifferChannel function
        %       would choose the channel.
        %    'ORX1_SN_LO' – SnRx operates in observation mode on ORx1 with
        %       SNIFFER LO synthesizer
        %    'ORX2_SN_LO' – SnRx operates in observation mode on ORx2 with
        %       SNIFFER LO synthesizer
        %    'SN_A' – SnRx operates in sniffer mode on SnRxA with SNIFFER
        %       LO synthesizer
        %    'SN_B' – SnRx operates in sniffer mode on SnRxB with SNIFFER
        %       LO synthesizer
        %    'SN_C' – SnRx operates in sniffer mode on SnRxC with SNIFFER
        %       LO synthesizer
        RFPortSelect = 'SN_A';
    end
    
    properties(Constant, Hidden)
        GainControlModeSet = matlab.system.StringSet({ ...
            'manual','automatic','hybrid'});
        RFPortSelectSet = matlab.system.StringSet({ ...
            'OFF',...
            'ORX1_TX_LO','ORX2_TX_LO',...
            'INTERNALCALS',...
            'OBS_SNIFFER',...
            'ORX1_SN_LO','ORX2_SN_LO',...
            'SN_A','SN_B','SN_C'});
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
        channel_names = {'voltage0_i','voltage0_q'};
    end
    
    properties (Nontunable, Hidden)
        devName = 'axi-ad9371-rx-obs-hpc';
    end
    
    methods
        %% Constructor
        function obj = ORx(varargin)
            coder.allowpcode('plain');
            obj = obj@adi.AD9371.Base(varargin{:});
        end
        % Check RFPortSelect
        function set.RFPortSelect(obj, value)
            obj.RFPortSelect = value;
            if obj.ConnectedToDevice
                obj.setAttributeRAW('voltage2','rf_port_select',value,false);
            end
        end
        % Check GainControlMode
        function set.GainControlMode(obj, value)
            obj.GainControlMode = value;
            if obj.ConnectedToDevice
                obj.setAttributeRAW('voltage2','rf_port_select','OFF',false);
                obj.setAttributeRAW('voltage2','gain_control_mode',value,false)
                obj.setAttributeRAW('voltage2','rf_port_select',obj.RFPortSelect,false); %#ok<MCSUP>
            end
        end
        % Check Gain
        function set.Gain(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', -4,'<=', 71}, ...
                '', 'Gain');
            assert(mod(value,1/4)==0, 'Gain must be a multiple of 0.25');
            obj.Gain = value;
            if obj.ConnectedToDevice && strcmp(obj.GainControlMode,'manual') %#ok<MCSUP>
                obj.setAttributeRAW('voltage2','rf_port_select','OFF',false);
                obj.setAttributeLongLong('voltage2','hardwaregain',value,false);
                obj.setAttributeRAW('voltage2','rf_port_select',obj.RFPortSelect,false); %#ok<MCSUP>
            end
        end
        % Check EnableQuadratureTracking
        function set.EnableQuadratureTracking(obj, value)
            obj.EnableQuadratureTracking = value;
            if obj.ConnectedToDevice
                obj.setAttributeRAW('voltage2','rf_port_select','OFF',false);
                obj.setAttributeBool('voltage2','quadrature_tracking_en',value,false);
                obj.setAttributeRAW('voltage2','rf_port_select',obj.RFPortSelect,false); %#ok<MCSUP>
            end
        end
        function set.LoopbackMode(obj, value)
            validateattributes( value, { 'double','single', 'uint32' }, ...
                { 'real', 'nonnegative','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',1}, ...
                '', 'LoopbackMode');    
            obj.LoopbackMode = value;
            if obj.ConnectedToDevice
                obj.setDebugAttributeLongLong('loopback_tx_obs',value);                    
            end
        end
    end
    
    methods (Access=protected)
        
        function CenterFrequencySet(obj,value)
            if obj.ConnectedToDevice
                obj.setAttributeRAW('voltage2','rf_port_select','OFF',false);
                obj.setAttributeLongLong('altvoltage2','RX_SN_LO_frequency',value,true);
                obj.setAttributeRAW('voltage2','rf_port_select',obj.RFPortSelect,false);
            end
        end

    end
    
    %% API Functions
    methods (Hidden, Access = protected)
                
        function setupInit(obj)
            % Write all attributes to device once connected through set
            % methods
            % Do writes directly to hardware without using set methods.
            % This is required sine Simulink support doesn't support
            % modification to nontunable variables at SetupImpl
            
            if obj.EnableCustomProfile
                writeProfileFile(obj);
            end
            
            obj.setAttributeRAW('voltage2','rf_port_select','OFF',false);
            
            obj.setAttributeRAW('voltage2','gain_control_mode',obj.GainControlMode,false);
            obj.setAttributeBool('voltage2','quadrature_tracking_en',obj.EnableQuadratureTracking,false);
            obj.setAttributeLongLong('altvoltage2','RX_SN_LO_frequency',obj.CenterFrequency ,true);
            % Loopback Mode
            obj.setDebugAttributeLongLong('loopback_tx_obs', obj.LoopbackMode);                    
            
            if strcmp(obj.GainControlMode,'manual')
                obj.setAttributeLongLong('voltage2','hardwaregain',obj.Gain,false);
            end
            
            obj.setAttributeRAW('voltage2','rf_port_select',obj.RFPortSelect,false);
            
        end
        
    end
    
end

