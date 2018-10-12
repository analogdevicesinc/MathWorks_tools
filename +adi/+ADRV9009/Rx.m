classdef Rx < adi.ADRV9009.Base
    %ADRV9009 Rx Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
        channel_names = {'voltage0_i','voltage0_q','voltage1_i','voltage1_q'};
    end
    
    properties (Nontunable, Hidden)
        devName = 'axi-adrv9009-rx-hpc';
    end
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.ADRV9009.Base(varargin{:});
        end
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        function varargout = stepImpl(obj)
            % Get the data
            [dataRAW, valid] = getData(obj);
            for k = 1:obj.channelCount/2
                i = dataRAW(k*2-1,:).';
                q = dataRAW(k*2,:).';
                varargout{k} = complex(i,q).'; %#ok<AGROW>
            end
            varargout{k+1} = valid;
        end
        
        function releaseChanBuffers(obj)
            % Destroy the buffers
            destroyBuf(obj);
            % Call the dev specific release
            %             streamDevRelease(obj);
            
            % Disable the channels
            if obj.enabledChannels
                for k=1:obj.channelCount
                    disableChannel(obj, obj.channel_names{k}, obj.isOutput);
                end
                obj.enabledChannels = false;
            end
        end
        
        function numOut = getNumOutputsImpl(obj)
            numOut = obj.channelCount/2 + 1;
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
            bName = 'ADRV9009';
        end
        
    end
end

