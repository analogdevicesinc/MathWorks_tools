classdef Tx < adi.ADRV9009.Base & adi.common.Tx
    % adi.ADRV9009ZU11EG.Tx Transmit data from the ADRV9009ZU11EG SOM
    %   The adi.ADRV9009ZU11EG.Tx System object is a signal sink that can tranmsit
    %   complex data from the ADRV9009ZU11EG.
    %
    %   tx = adi.ADRV9009ZU11EG.Tx;
    %   tx = adi.ADRV9009ZU11EG.Tx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/ADRV9009.pdf">ADRV9009 Datasheet</a>
    
    properties
        %AttenuationChannel0 Attenuation Channel 0
        %   Attentuation specified as a scalar from -89.75 to 0 dB with a
        %   resolution of 0.25 dB.
        AttenuationChannel0 = -30;
        %AttenuationChannel1 Attenuation Channel 1
        %   Attentuation specified as a scalar from -89.75 to 0 dB with a
        %   resolution of 0.25 dB.
        AttenuationChannel1 = -30;
        %AttenuationChannel2 Attenuation Channel 2
        %   Attentuation specified as a scalar from -89.75 to 0 dB with a
        %   resolution of 0.25 dB.
        AttenuationChannel2 = -30;
        %AttenuationChannel3 Attenuation Channel 3
        %   Attentuation specified as a scalar from -89.75 to 0 dB with a
        %   resolution of 0.25 dB.
        AttenuationChannel3 = -30;
    end
        
    properties (Hidden, Nontunable, Access = protected)
        isOutput = true;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Tx';
        channel_names = {'voltage0','voltage1','voltage2','voltage3',...
            'voltage4','voltage5','voltage6','voltage7'};
    end
    
    properties (Nontunable, Hidden)
        devName = 'axi-adrv9009-tx-hpc';
    end
    
    properties(Hidden)
        ADRV9009_B_Tx = adi.ADRV9009.Tx(...
            'phyDevName','adrv9009-phy-b',...
            'uri','ip:192.168.0.101',...
            'channelCount',0);
    end
    
    methods
        %% Constructor
        function obj = Tx(varargin)
            coder.allowpcode('plain');
            obj = obj@adi.ADRV9009.Base(varargin{:});
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
        % Check Attentuation
        function set.AttenuationChannel2(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', -89.75,'<=', 0}, ...
                '', 'AttenuationChannel2');
            assert(mod(value,1/4)==0, 'Attentuation must be a multiple of 0.25');
            obj.AttenuationChannel2 = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.ADRV9009_B_Tx.setAttributeLongLong(id,'hardwaregain',value,true);
            end
        end
        % Check Attentuation
        function set.AttenuationChannel3(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', -89.75,'<=', 0}, ...
                '', 'AttenuationChannel3');
            assert(mod(value,1/4)==0, 'Attentuation must be a multiple of 0.25');
            obj.AttenuationChannel3 = value;
            if obj.ConnectedToDevice
                id = 'voltage1';
                obj.ADRV9009_B_Tx.setAttributeLongLong(id,'hardwaregain',value,true);
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
            id = sprintf('altvoltage%d',strcmp(obj.Type,'Tx'));
            id = 'altvoltage0';
            obj.setAttributeLongLong(id,'frequency',obj.CenterFrequency ,true);
            obj.setAttributeLongLong('voltage0','hardwaregain',obj.AttenuationChannel0,true);
            obj.setAttributeLongLong('voltage1','hardwaregain',obj.AttenuationChannel1,true);
            obj.ToggleDDS(strcmp(obj.DataSource,'DDS'));
            if strcmp(obj.DataSource,'DDS')
                obj.DDSUpdate();
            end
        end
        
    end
    
end

