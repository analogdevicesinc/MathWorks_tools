classdef Tx < adi.ADRV9009.Base
    %ADRV9009 Rx Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Nontunable)
        Mode = 'DMA'; 
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = true;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Tx';
        channel_names = {'voltage0','voltage1','voltage2','voltage3'};
    end
    
    properties (Nontunable, Hidden)
        devName = 'axi-adrv9009-tx-hpc';
    end
    
    methods
        %% Constructor
        function obj = Tx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.ADRV9009.Base(varargin{:});
        end
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        function stepImpl(obj,varargin)

            if strcmp(obj.Mode,'DDS')
                error('Cannot send data to DMA with DDS enabled');
            end
            c = obj.channelCount/2;
            N = c*length(varargin{1})*2;
            outputData = complex(zeros(N,1));
            % Convert to single vector
            %%%% CAN TELL BLOCK COMPLEXITY
%             for k = 1:nargin-1
%                 outputData(2*k-1:obj.channelCount:end) = real(varargin{k});
%                 outputData(2*k:obj.channelCount:end) = imag(varargin{k});
%             end
            sendData(obj,outputData);
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

