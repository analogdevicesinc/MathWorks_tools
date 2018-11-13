classdef Rx < adi.AD9680.Base & adi.common.Rx
    % adi.AD9680.Rx Receive data from the AD9680 high speed ADC
    %   The adi.AD9680.Rx System object is a signal source that can receive
    %   complex data from the AD9680.
    %
    %   rx = adi.AD9680.Rx;
    %   rx = adi.AD9680.Rx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9680.pdf">AD9680 Datasheet</a>
    %
    %   See also adi.DAQ2.Rx
    
    properties (Constant)
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar
        %   in samples per second. This value is constant
        SamplingRate = 1e9;
    end
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
        channel_names = {'voltage0','voltage1'};
    end
    
    properties (Nontunable, Hidden)
        devName = 'axi-ad9680-hpc';
    end
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9680.Base(varargin{:});
        end
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        function numOut = getNumOutputsImpl(obj)
            numOut = ceil(obj.channelCount/2) + 1; % +1 for valid
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
            numOut = ceil(obj.channelCount/2) + 1; % +1 for valid
            varargout = cell(1,numOut);
            for k=1:numOut-1
                varargout{k} = ['chan',num2str(k)];
            end
            varargout{numOut} = 'valid';
        end
        
        function varargout = getOutputSizeImpl(obj)
            % Return size for each output port
            numOut = ceil(obj.channelCount/2) + 1; % +1 for valid
            varargout = cell(1,numOut);
            for k=1:numOut-1
                varargout{k} = [obj.SamplesPerFrame,1];
            end
            varargout{numOut} = [1,1];
        end
        
        function varargout = getOutputDataTypeImpl(obj)
            % Return data type for each output port
            numOut = ceil(obj.channelCount/2) + 1; % +1 for valid
            varargout = cell(1,numOut);
            for k=1:numOut-1
                varargout{k} = "int16";
            end
            varargout{numOut} = "logical";
        end
        
        function varargout = isOutputComplexImpl(obj)
            % Return true for each output port with complex data
            numOut = ceil(obj.channelCount/2) + 1; % +1 for valid
            varargout = cell(1,numOut);
            for k=1:numOut-1
                varargout{k} = true;
            end
            varargout{numOut} = false;
        end
        
        function varargout = isOutputFixedSizeImpl(obj)
            % Return true for each output port with fixed size
            numOut = ceil(obj.channelCount/2) + 1; % +1 for valid
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
            bName = 'AD9680';
        end
        
    end
end

