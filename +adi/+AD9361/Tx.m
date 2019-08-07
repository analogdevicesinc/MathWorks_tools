classdef Tx < adi.AD9361.Base & adi.common.Tx
    % adi.AD9361.Tx Transmit data from the AD9361 transceiver
    %   The adi.AD9361.Tx System object is a signal sink that can tranmsit
    %   complex data from the AD9361.
    %
    %   tx = adi.AD9361.Tx;
    %   tx = adi.AD9361.Tx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9361.pdf">AD9361 Datasheet</a>
    %
    %   See also adi.FMComms2.Tx, adi.FMComms3.Tx, adi.FMComms5.Tx
    
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
        %AttenuationChannel0 Attenuation Channel 0
        %   Attentuation specified as a scalar from -89.75 to 0 dB with a
        %   resolution of 0.25 dB.
        AttenuationChannel0 = -30;
        %AttenuationChannel1 Attenuation Channel 1
        %   Attentuation specified as a scalar from -89.75 to 0 dB with a
        %   resolution of 0.25 dB.
        AttenuationChannel1 = -30;
    end
        
    properties (Hidden, Nontunable, Access = protected)
        isOutput = true;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Tx';
        channel_names = {'voltage0','voltage1','voltage2','voltage3'};
    end
    
    properties (Nontunable, Hidden)
        devName = 'cf-ad9361-dds-core-lpc';
    end
    
    properties
        %RFPortSelect RF Port Select
        %    'A'
        %    'B'
        RFPortSelect = 'A';
    end
    
    properties(Constant, Hidden)
        RFPortSelectSet = matlab.system.StringSet({'A', 'B'});
    end     
    
    methods
        %% Constructor
        function obj = Tx(varargin)
            coder.allowpcode('plain');
            obj = obj@adi.AD9361.Base(varargin{:});
        end
        % Check RFPortSelect
        function set.RFPortSelect(obj, value)
            obj.RFPortSelect = value;
            if obj.ConnectedToDevice
                obj.setAttributeRAW('voltage0','rf_port_select',value,false);
            end
        end
        % Check Attentuation
        function set.AttenuationChannel0(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', -89.75,'<=', 0}, ...
                '', 'Attenuation');
            assert(mod(value,1/4)==0, 'Attentuation must be a multiple of 0.25');
            obj.AttenuationChannel0 = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeLongLong(id,'hardwaregain',value,true);
            end
        end
        % Check Attentuation
        function set.AttenuationChannel1(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', -89.75,'<=', 0}, ...
                '', 'Attenuation');
            assert(mod(value,1/4)==0, 'Attentuation must be a multiple of 0.25');
            obj.AttenuationChannel1 = value;
            if obj.ConnectedToDevice
                id = 'voltage1';
                obj.setAttributeLongLong(id,'hardwaregain',value,true);
            end
        end
        % Check CenterFrequency
        function set.CenterFrequency(obj, value)
            if isa(obj,'adi.AD9363.Tx')
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
            if isa(obj,'adi.AD9363.Tx')
                validateattributes( value, { 'double','single' }, ...
                    { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',200e3,'<=',20e6}, ...
                    '', 'RFBandwidth');
            else
                validateattributes( value, { 'double','single' }, ...
                    { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',200e3,'<=',40e6}, ...
                    '', 'RFBandwidth');
                
            end
            obj.RFBandwidth = value;
            if obj.ConnectedToDevice && ~obj.EnableCustomFilter
                id = 'voltage0';
                obj.setAttributeLongLong(id,'rf_bandwidth',value,strcmp(obj.Type,'Tx'),30);
            end
        end
        % Check SampleRate
        function set.SamplingRate(obj, value)
            if isa(obj,'adi.AD9363.Tx')
                validateattributes( value, { 'double','single' }, ...
                    { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',520833,'<=',20e6}, ...
                    '', 'SamplingRate');
            else
                validateattributes( value, { 'double','single' }, ...
                    { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',520833,'<=',61.44e6}, ...
                    '', 'SamplingRate');
                
            end
            obj.SamplingRate = value;
            if obj.ConnectedToDevice && ~obj.EnableCustomFilter
                if libisloaded('libad9361')
                    calllib('libad9361','ad9361_set_bb_rate',obj.iioDevPHY,int32(value));
                else
                    id = 'voltage0';
                    obj.setAttributeLongLong(id,'sampling_frequency',value,true,4);
                end
            end
        end
    end
       
    %% API Functions
    methods (Hidden, Access = protected)
        
        function setupInit(obj)
            % Write all attributes to device once connected through set
            % methods
            setupLibad9361(obj);
            % Do writes directly to hardware without using set methods.
            % This is required sine Simulink support doesn't support
            % modification to nontunable variables at SetupImpl
            id = 'altvoltage1';
            obj.setAttributeLongLong(id,'frequency',obj.CenterFrequency ,true,4);
            if libisloaded('libad9361')
                calllib('libad9361','ad9361_set_bb_rate',obj.iioDevPHY,int32(obj.SamplingRate));
            else
                obj.setAttributeLongLong('voltage0','sampling_frequency',obj.SamplingRate,true,4);
            end
            obj.setAttributeLongLong('voltage0','hardwaregain',obj.AttenuationChannel0,true);
            if obj.channelCount>2
                obj.setAttributeLongLong('voltage1','hardwaregain',obj.AttenuationChannel1,true);
            end
            obj.setAttributeLongLong('voltage0','rf_bandwidth',obj.RFBandwidth ,strcmp(obj.Type,'Tx'));            
            obj.ToggleDDS(strcmp(obj.DataSource,'DDS'));
            if strcmp(obj.DataSource,'DDS')
                obj.DDSUpdate();
            end
            obj.setAttributeRAW('voltage0','rf_port_select',obj.RFPortSelect,true);
        end
        
    end
    
end

