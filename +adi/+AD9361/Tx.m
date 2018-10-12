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
        %Attenuation Attenuation
        %   Attentuation specified as a scalar from -89.75 to 0 dB with a
        %   resolution of 0.25 dB.
        Attenuation = -30;
        %DDSFrequencies DDS Frequencies
        %   Frequencies values in Hz of the four DDS tone generators per
        %   channel. Input is a [2x4] matrix.
        DDSFrequencies = 5e5*ones(2,4);
        %DDSScales DDS Scales
        %   Scale of DDS tones in range [0,1]. Input is a [2x4] matrix.
        DDSScales = [1,0,1,0;0,0,0,0];
        %DDSPhases DDS Phases
        %   Phases of DDS tones in range [0,360000]. Input is a [2x4] matrix.
        DDSPhases = [0,0,90000,0;0,0,0,0];
    end
    
    properties (Nontunable)
        %DataSource Data Source
        %   Data source, specified as one of the following: 
        %   'DMA' — Specify the host as the source of the data.
        %   'DDS' — Specify the DDS on the radio hardware as the source 
        %   of the data. In this case, each channel has two additive tones.
        DataSource = 'DMA';
        %EnableCyclicBuffers Enable Cyclic Buffers
        %   Enable Cyclic Buffers, configures transmit buffers to be
        %   cyclic, which makes them continuously repeat
        EnableCyclicBuffers = false;
    end
    
    properties(Constant, Hidden)
        DataSourceSet = matlab.system.StringSet({ ...
            'DMA','DDS'});
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
    
    methods
        %% Constructor
        function obj = Tx(varargin)
            coder.allowpcode('plain');
            obj = obj@adi.AD9361.Base(varargin{:});
        end
        % Check Attentuation
        function set.Attenuation(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', -89.75,'<=', 0}, ...
                '', 'Attenuation');
            assert(mod(value,1/4)==0, 'Attentuation must be a multiple of 0.25');
            obj.Attenuation = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeLongLong(id,'hardwaregain',value,true);
            end
        end
        % Check DataSource
        function set.DataSource(obj, value)
            obj.DataSource = value;
            if obj.ConnectedToDevice
                obj.ToggleDDS(strcmp(value,'DDS'));
            end
        end
        
    end
    
    methods (Access=protected)
        % Only show DDS settings when DataSource set to
        % 'DDS'
        function flag = isInactivePropertyImpl(obj, prop)
            flag = strcmpi(prop,'DDSFrequencies') &&...
                ~strcmpi(obj.DataSource, 'DDS');
            flag = flag || strcmpi(prop,'DDSScales') &&...
                ~strcmpi(obj.DataSource, 'DDS');
            flag = flag || strcmpi(prop,'DDSPhases') &&...
                ~strcmpi(obj.DataSource, 'DDS');
        end
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        function numIn = getNumInputsImpl(obj)
            if strcmp(obj.DataSource,'DDS')
                numIn = 0;
            else
                numIn = 1;
            end
        end
        
        function setupInit(obj)
            % Write all attributes to device once connected through set
            % methods
            obj.CenterFrequency = obj.CenterFrequency;
            obj.SamplingRate = obj.SamplingRate;
            obj.Attenuation = obj.Attenuation;
            obj.RFBandwidth = obj.RFBandwidth;
            obj.DataSource = obj.DataSource;
            obj.DDSUpdate();
        end
        
    end
    
end

