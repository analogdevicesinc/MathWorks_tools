classdef (Abstract) Base < matlabshared.libiio.base & ...
        matlab.system.mixin.CustomIcon
    %AD9371 Base Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Nontunable)
        SamplesPerFrame = 2^15;
        channelCount = 2;
    end
    
    properties(Nontunable, Hidden)
        Timeout = Inf;
        kernelBuffersCount = 2;
        dataTypeStr = 'int16';
    end
    
    properties (Hidden)
       enabledChannels = false; 
    end
    
    properties (Abstract, Hidden, Constant)
       Type 
    end
    
    methods
        %% Constructor
        function obj = Base(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@matlabshared.libiio.base(varargin{:});
            %             obj.isOutput = true;
        end
        % Check SamplesPerFrame
        function set.SamplesPerFrame(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>',0,'<',2^20+1}, ...
                '', 'SamplesPerFrame');
            obj.SamplesPerFrame = value;
        end
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
%         function releaseChanBuffers(obj)
%             % Destroy the buffers
%             destroyBuf(obj);
%             % Call the dev specific release
%             %             streamDevRelease(obj);
% 
%             % Disable the channels
%             if obj.enabledChannels
%             for k=1:obj.channelCount
%                 disableChannel(obj, obj.channel_names{k}, obj.isOutput);
%             end
%             obj.enabledChannels = false;
%             end
%         end
%         
%         function status = configureChanBuffers(obj)
%             % Enable the channel(s)
%             for k=1:obj.channelCount
%                 enableChannel(obj, obj.channel_names{k}, obj.isOutput);
%             end
%             obj.enabledChannels = true;
%             
%             % Create the buffers
%             status = createBuf(obj);
%             if status
% %                 disableChannel(obj, obj.channel, obj.isOutput);
%                 releaseChanBuffers(obj);
%                 cerrmsg(obj,status,['Failed to create buffer for: ' obj.devName]);
%                 return
%             end
%         end
        
        function icon = getIconImpl(obj)
            icon = sprintf(['AD9371 ',obj.Type]);
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
            bName = 'AD9371';
        end
        
    end
end

