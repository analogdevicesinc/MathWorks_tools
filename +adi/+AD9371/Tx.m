classdef Tx < adi.AD9371.Base & adi.common.Tx
    % adi.AD9371.Tx Transmit data from the AD9371 transceiver
    %   The adi.AD9371.Tx System object is a signal sink that can tranmsit
    %   complex data from the AD9371.
    %
    %   tx = adi.AD9371.Tx;
    %   tx = adi.AD9371.Tx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9371.pdf">AD9371 Datasheet</a>
    
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
        devName = 'axi-ad9371-tx-hpc';
    end
    
    methods
        %% Constructor
        function obj = Tx(varargin)
            coder.allowpcode('plain');
            obj = obj@adi.AD9371.Base(varargin{:});
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
            
            id = sprintf('altvoltage%d',strcmp(obj.Type,'Tx'));
            obj.setAttributeLongLong(id,'TX_LO_frequency',obj.CenterFrequency ,true);
            obj.setAttributeLongLong('voltage0','hardwaregain',obj.AttenuationChannel0,true);
            obj.setAttributeLongLong('voltage1','hardwaregain',obj.AttenuationChannel1,true);
            
            obj.ToggleDDS(strcmp(obj.DataSource,'DDS'));
            if strcmp(obj.DataSource,'DDS')
                obj.DDSUpdate();
            end
        end
        
    end
    
end

