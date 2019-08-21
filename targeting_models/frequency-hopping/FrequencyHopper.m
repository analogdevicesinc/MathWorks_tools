classdef FrequencyHopper < adi.common.Attribute & ...
        adi.common.DebugAttribute & adi.common.Rx & ...
        matlabshared.libiio.base
    %FrequencyHopper Frequency Hopper controller
    properties
        DwellSamples = 1024;
        ManualProfileIndex = 0;
    end
    
    properties (Logical)
        ManualProfileEnable = false;
        HoppingEnable = false;
        ForcedEnabled = true;
    end
    
    properties (Hidden)
       channelCount = 0; 
    end
    
    properties(Nontunable, Hidden)
        Timeout = Inf;
        kernelBuffersCount = 0;
        dataTypeStr = 'int16';
        phyDevName = 'axi-hopper';
        iioDevPHY
        devName = 'axi-hopper';
        SamplesPerFrame = 0;
    end
    
    properties (Hidden, Constant, Logical)
        ComplexData = false;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
        channel_names = {''};
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    methods
        %% Constructor
        function obj = FrequencyHopper(varargin)
            coder.allowpcode('plain');
            obj = obj@matlabshared.libiio.base(varargin{:});
        end
        % Destructor
        function delete(obj)
        end
        % Check SamplesPerFrame
        function set.DwellSamples(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>',0,'<=',2^32}, ...
                '', 'DwellSamples');
            obj.DwellSamples = value;
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('dwell_samples',num2str(value));
            end
        end
        % Check ManualProfileIndex
        function set.ManualProfileIndex(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>',0,'<=',7}, ...
                '', 'DwellSamples');
            obj.ManualProfileIndex = value;
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('manual_profile_indx',num2str(value));
            end
        end

        % Check ManualProfileEnable
        function set.ManualProfileEnable(obj, value)
            obj.ManualProfileEnable = value;
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('manual_profile_enable',num2str(value));
            end
        end
        % Check HoppingEnable
        function set.HoppingEnable(obj, value)
            obj.HoppingEnable = value;
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('hopping_enable',num2str(value));
            end
        end
        % Check HoppingEnable
        function set.ForcedEnabled(obj, value)
            obj.ForcedEnabled = value;
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('forced_enable',num2str(value));
            end
        end
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        function setupImpl(obj)
            % Setup LibIIO
            setupLib(obj);
            
            % Initialize the pointers
            initPointers(obj);
            
            getContext(obj);
            
            setContextTimeout(obj);
            
            % Get the device
            obj.iioDev = getDev(obj, obj.devName);
            
            obj.needsTeardown = true;
            
            % Pre-calculate values to be used faster in stepImpl()
            obj.pIsInSimulink = coder.const(obj.isInSimulink);
            obj.pNumBufferBytes = coder.const(obj.numBufferBytes);
            setupInit(obj);
        end
        function [data,valid] = stepImpl(~)
            data = 0;
            valid = false;
        end
        function setupInit(obj)
            % Do writes directly to hardware without using set methods.
            % This is required sine Simulink support doesn't support
            % modification to nontunable variables at SetupImpl
            obj.setDeviceAttributeRAW('dwell_samples',num2str(obj.DwellSamples));
            obj.setDeviceAttributeRAW('manual_profile_indx',num2str(obj.ManualProfileIndex));
            obj.setDeviceAttributeRAW('manual_profile_enable',num2str(obj.ManualProfileEnable));
            obj.setDeviceAttributeRAW('hopping_enable',num2str(obj.HoppingEnable));
            obj.setDeviceAttributeRAW('forced_enable',num2str(obj.ForcedEnabled));
        end
    end
    
    %% External Dependency Methods
    methods (Hidden, Static)
        
        function tf = isSupportedContext(bldCfg)
            tf = matlabshared.libiio.ExternalDependency.isSupportedContext(bldCfg);
        end
        
        function updateBuildInfo(buildInfo, bldCfg)
            % Call the matlabshared.libiio.method first
            matlabshared.libiio.ExternalDependency.updateBuildInfo(buildInfo, bldCfg);
        end
        
    end
end



