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
    
    methods
        %% Constructor
        function obj = Tx(varargin)
            coder.allowpcode('plain');
            obj = obj@adi.AD9361.Base(varargin{:});
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
        
    end
    
    methods (Access=protected)
        function setupImpl(obj,data)
            if strcmp(obj.DataSource,'DMA')
                obj.SamplesPerFrame = size(data,1);
            end
            % Call the superclass method
            setupImpl@matlabshared.libiio.base(obj);
        end

        % Hide unused parameters when in specific modes
        function flag = isInactivePropertyImpl(obj, prop)
            % Call the superclass method
            flag = isInactivePropertyImpl@adi.common.RxTx(obj,prop);
        end
        
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        function numIn = getNumInputsImpl(obj)
            if strcmp(obj.DataSource,'DDS')
                numIn = 0;
            else
                numIn = obj.channelCount/2;
            end
        end
        
        function setupInit(obj)
            % Write all attributes to device once connected through set
            % methods
            % Do writes directly to hardware without using set methods.
            % This is required sine Simulink support doesn't support
            % modification to nontunable variables at SetupImpl
            id = 'altvoltage1';
            obj.setAttributeLongLong(id,'frequency',obj.CenterFrequency ,true);
            if libisloaded('libad9361')
                calllib('libad9361','ad9361_set_bb_rate',obj.iioDevPHY,int32(obj.SamplingRate));
            else
                obj.setAttributeLongLong('voltage0','sampling_frequency',obj.SamplingRate,true);
            end
            obj.setAttributeLongLong('voltage0','hardwaregain',obj.AttenuationChannel0,true);
            obj.setAttributeLongLong('voltage1','hardwaregain',obj.AttenuationChannel1,true);
            obj.setAttributeLongLong('voltage0','rf_bandwidth',obj.RFBandwidth ,strcmp(obj.Type,'Tx'));            
            obj.ToggleDDS(strcmp(obj.DataSource,'DDS'));
            if strcmp(obj.DataSource,'DDS')
                obj.DDSUpdate();
            end
        end
        
    end
    
end

