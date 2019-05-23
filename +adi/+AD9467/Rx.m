classdef Rx < adi.AD9467.Base & adi.common.Rx & adi.common.ADC
    % adi.AD9467.Rx Receive data from the AD9467 high speed ADC
    %   The adi.AD9467.Rx System object is a signal source that can receive
    %   complex data from the AD9467.
    %
    %   rx = adi.AD9467.Rx;
    %   rx = adi.AD9467.Rx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9467.pdf">AD9467 Datasheet</a>
    
    properties (Dependent)
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar
        %   in samples per second. This value read from the hardware after
        %   the object is setup.
        SamplingRate
    end
    
    properties
        %TestMode Test Mode
        %   Select ADC test mode. Options are:
        %   'off'
        %   'midscale_short'
        %   'pos_fullscale'
        %   'neg_fullscale'
        %   'checkerboard'
        %   'pn_long'
        %   'pn_short'
        %   'one_zero_toggle'
        TestMode = 'off';
        %FilterHighPass3dbFrequency Filter High Pass 3db Frequency
        %   FilterHighPass3dbFrequency
        FilterHighPass3dbFrequency = 0;
        %Scale Scale
        %   Scale received data. Possible options are:
        %   0.030517 0.032043 0.033569 0.035095 0.036621 0.038146
        Scale = 0.038146;
    end
    
    properties(Constant, Hidden)
        TestModeSet = matlab.system.StringSet({ ...
            'off','midscale_short', 'pos_fullscale', 'neg_fullscale',...
            'checkerboard', 'pn_long', 'pn_short', 'one_zero_toggle'});
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
        channel_names = {'voltage0'};
    end
    
    properties (Nontunable, Hidden)
        devName = 'cf-ad9467-core-lpc';
    end
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9467.Base(varargin{:});
        end
        % Check TestMode
        function set.TestMode(obj, value)
            obj.TestMode = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeRAW(id,'test_mode',value,false);
            end
        end
        % Check FilterHighPass3dbFrequency
        function set.FilterHighPass3dbFrequency(obj, value)
            obj.FilterHighPass3dbFrequency = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeLongLong(id,'filter_high_pass_3db_frequency',value,false);
            end
        end
        % Check Scale
        function set.Scale(obj, value)
            options = [0.030517 0.032043 0.033569 0.035095 0.036621 0.038146];
            if ~any(value==options)
               error(['Scale must be one of ',num2str(options)]);
            end
            obj.Scale = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeRAW(id,'scale',num2str(value),false);
            end
        end
        function value = get.SamplingRate(obj)
            if obj.ConnectedToDevice
                id = 'voltage0';
                value = obj.getAttributeLongLong(id,'sampling_frequency',false);
            else
                value = 0;
            end
        end

    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        function numOut = getNumOutputsImpl(obj)
            numOut = ceil(obj.channelCount) + 1; % +1 for valid
        end
        
        function setupInit(obj)
            % Write all attributes to device once connected through set
            % methods
            id = 'voltage0';
            
            obj.setAttributeRAW(id,'test_mode',obj.TestMode,false);
            obj.setAttributeLongLong(id,'filter_high_pass_3db_frequency',...
                obj.FilterHighPass3dbFrequency,false);
            obj.setAttributeRAW(id,'scale',num2str(obj.Scale),false);
            
            obj.setAttributeLongLong(id,'calibbias',obj.CalibrationBias,...
                false);
            obj.setAttributeRAW(id,'calibphase',...
                num2str(obj.CalibrationPhase),false);
            obj.setAttributeRAW(id,'calibscale',...
                num2str(obj.CalibrationScale),false);
            
            
        end
        
        % Hide unused parameters when in specific modes
        function flag = isInactivePropertyImpl(obj, prop)
            % Call the superclass method
            flag = isInactivePropertyImpl@adi.common.RxTx(obj,prop);
        end
    end
    
    methods (Access=protected)
        
        function varargout = getOutputNamesImpl(obj)
            % Return output port names for System block
            numOut = ceil(obj.channelCount) + 1; % +1 for valid
            varargout = cell(1,numOut);
            for k=1:numOut-1
                varargout{k} = ['chan',num2str(k)];
            end
            varargout{numOut} = 'valid';
        end
        
        function varargout = getOutputSizeImpl(obj)
            % Return size for each output port
            numOut = ceil(obj.channelCount) + 1; % +1 for valid
            varargout = cell(1,numOut);
            for k=1:numOut-1
                varargout{k} = [obj.SamplesPerFrame,1];
            end
            varargout{numOut} = [1,1];
        end
        
        function varargout = getOutputDataTypeImpl(obj)
            % Return data type for each output port
            numOut = ceil(obj.channelCount) + 1; % +1 for valid
            varargout = cell(1,numOut);
            for k=1:numOut-1
                varargout{k} = "int16";
            end
            varargout{numOut} = "logical";
        end
        
        function varargout = isOutputComplexImpl(obj)
            % Return true for each output port with complex data
            numOut = ceil(obj.channelCount) + 1; % +1 for valid
            varargout = cell(1,numOut);
            for k=1:numOut-1
                varargout{k} = true;
            end
            varargout{numOut} = false;
        end
        
        function varargout = isOutputFixedSizeImpl(obj)
            % Return true for each output port with fixed size
            numOut = ceil(obj.channelCount) + 1; % +1 for valid
            varargout = cell(1,numOut);
            for k=1:numOut
                varargout{k} = true;
            end
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
        
        function bName = getDescriptiveName(~)
            bName = 'AD9467';
        end
        
    end
end

