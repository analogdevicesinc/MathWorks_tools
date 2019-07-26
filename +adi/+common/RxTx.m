classdef (Abstract) RxTx < matlabshared.libiio.base
    
    properties (Nontunable, Hidden)
        enabledChannels = false;
        ConnectedToDevice = false;
    end
    
    properties(Nontunable)
        %EnabledChannels Enabled Channels
        %   Indexs of channels to be enabled. Input should be a [1xN]
        %   vector with the indexes of channels to be enabled. Order is
        %   irrelevant
        EnabledChannels = 1;
    end
    
    properties (Dependent,Hidden)
        channelCount
    end
    
    properties (Nontunable, Hidden)
        DataTimeout = 5;
    end
    
    properties (Abstract, Hidden, Constant)
        Type
    end
    
    properties (Abstract, Hidden, Constant, Logical)
        ComplexData
    end
    
    
    %% Abstract API Functions
    methods (Abstract, Hidden, Access = protected)
        % Write attributes to device once connected
        setupInit(obj)
    end
    
    %% Static Internal API Functions
    methods (Static, Hidden)
        % Count
        % Method keeps track of existing system objects if their state is
        % needed by others. This is typically used for profile management
        % between RX and TX variants of the same device
        function [out,props] = Count(inc,handle,property)
            persistent Classes;
            persistent Properties;
            if isempty(Classes)
                Classes = [];
                Properties = [];
            end
            if nargin == 0
                inc = 0;
            end
            if inc == 1
                warnStruct = warning('off','MATLAB:structOnObject');
                Properties = [Properties(:)',{struct(handle)}];
                warning(warnStruct);
                Classes = [Classes(:)',{class(handle)}];
            elseif inc == -1
                removals = [];
                for i = 1:length(Classes)
                      if strcmpi(Properties{i}.uri,handle.uri) && strcmpi(Classes{i},class(handle))
                          removals = [removals; i]; %#ok<*AGROW>
                      end
                end
                Properties(removals) = [];
                Classes(removals) = [];
            end
            props = [];
            if nargin == 3
                for i = 1:length(Properties)
                    if ~strcmpi(Classes{i},class(handle))
                        props = [props(:)',{Properties{i}.(property)}];
                    end
                end
            end
            out = length(Classes);
        end
    end
    
    %% API Functions
    methods
        % Check EnabledChannels
        function set.EnabledChannels(obj, value)
            s = size(value);
            assert(s(1)==1,'EnabledChannels must be a row vector');
            
            maxChan = length(obj.channel_names)/(1+obj.ComplexData);
            assert(max(value)<=maxChan,...
                sprintf('EnabledChannels values cannot exceed %d',maxChan));
            
            assert(min(value)>0,'EnabledChannels values must > 0');
            
            assert(length(unique(value))==length(value),...
                'EnabledChannels must contain all unique values');
            
            obj.EnabledChannels = sort(value);
        end
        
        function value = get.channelCount(obj)
            value = length(obj.EnabledChannels) * (1+obj.ComplexData);
        end
        % Destructor
        function delete(obj)
            releaseImpl(obj);
        end
    end
    
    %% Hidden API Functions
    methods (Hidden, Access = protected)
        
        function setupImpl(obj)
            % Call the superclass method
            obj.Count(1,obj);
            setupImpl@matlabshared.libiio.base(obj);
        end
        
        function releaseImpl(obj)
            obj.Count(-1,obj);
            releaseImpl@matlabshared.libiio.base(obj);
        end
        
        % Hide unused parameters when in specific modes
        function flag = isInactivePropertyImpl(obj, prop)
            flag = strcmpi(prop,'enIO');
            % TX/RX
            if isprop(obj,'EnableCustomProfile')
                flag = flag || strcmpi(prop,'CustomProfileFileName') && ~obj.EnableCustomProfile;
                if obj.EnableCustomProfile
                    flag = flag || strcmpi(prop,'RFBandwidth');
                    flag = flag || strcmpi(prop,'SamplingRate');
                end
            end
            if isprop(obj,'EnableCustomFilter')
                flag = flag || strcmpi(prop,'CustomFilterFileName') && ~obj.EnableCustomFilter;
                if obj.EnableCustomFilter
                    flag = flag || strcmpi(prop,'RFBandwidth');
                    flag = flag || strcmpi(prop,'SamplingRate');
                end
            end
            % TX
            if isprop(obj,'DataSource')
                flag = flag || strcmpi(prop,'DDSFrequencies') &&...
                    ~strcmpi(obj.DataSource, 'DDS');
                flag = flag || strcmpi(prop,'DDSScales') &&...
                    ~strcmpi(obj.DataSource, 'DDS');
                flag = flag || strcmpi(prop,'DDSPhases') &&...
                    ~strcmpi(obj.DataSource, 'DDS');
                flag = flag || strcmpi(prop,'EnableCyclicBuffers') &&...
                    ~strcmpi(obj.DataSource, 'DMA');
                flag = flag || strcmpi(prop,'EnabledChannels') &&...
                    ~strcmpi(obj.DataSource, 'DMA');
            end
            flag = flag || strcmpi(prop,'SamplesPerFrame') && strcmp(obj.Type,'Tx');
            if obj.channelCount < 3
                flag = flag || strcmpi(prop,'AttenuationChannel1');
            end
            if obj.isInSimulink
                flag = flag || strcmpi(prop,'EnableCyclicBuffers');
            end
            % RX
            if isprop(obj,'GainControlMode')
                flag = flag || strcmpi(prop,'GainChannel0') &&...
                    ~strcmpi(obj.GainControlMode, 'manual');
                flag = flag || strcmpi(prop,'GainChannel1') &&...
                    ~strcmpi(obj.GainControlMode, 'manual');
            elseif isprop(obj,'GainControlModeChannel0')
                flag = flag || strcmpi(prop,'GainChannel0') &&...
                    ~strcmpi(obj.GainControlModeChannel0, 'manual');
                flag = flag || strcmpi(prop,'GainChannel1') &&...
                    ~strcmpi(obj.GainControlModeChannel1, 'manual');
            end
            if obj.channelCount < 3
                flag = flag || strcmpi(prop,'GainChannel1');
                flag = flag || strcmpi(prop,'GainControlModeChannel1');
                flag = flag || strcmpi(prop,'EnableQuadratureTrackingChannel1');
            end
        end
        
        function releaseChanBuffers(obj)
            % Destroy the buffers
            destroyBuf(obj);
            
            % Disable the channels
            if obj.enabledChannels
                ec = length(obj.EnabledChannels);
                if obj.ComplexData
                    for k=1:ec
                        indx = obj.EnabledChannels(k)*2-1;
                        name = obj.channel_names{indx};
                        disableChannel(obj, obj.iioDev, name, obj.isOutput);
                        name = obj.channel_names{indx+1};
                        disableChannel(obj, obj.iioDev, name, obj.isOutput);
                        
                    end
                else
                    for k=1:obj.channelCount
                        name = obj.channel_names{obj.EnabledChannels(k)};
                        disableChannel(obj, obj.iioDev, name, obj.isOutput);
                    end
                end
                obj.enabledChannels = false;
            end
            obj.ConnectedToDevice = false;
        end
        
        function status = configureChanBuffers(obj)
            
            obj.ConnectedToDevice = true;
            obj.bufIsCyclic = obj.EnableCyclicBuffers;
            
            % Set attributes
            setupInit(obj);
            
            % Enable the channel(s)
            ec = length(obj.EnabledChannels);
            if obj.ComplexData
                for k=1:ec
                    indx = obj.EnabledChannels(k)*2-1;
                    name = obj.channel_names{indx};
                    enableChannel(obj, obj.iioDev, name, obj.isOutput);
                    name = obj.channel_names{indx+1};
                    enableChannel(obj, obj.iioDev, name, obj.isOutput);
                    
                end
            else
                for k=1:obj.channelCount
                    name = obj.channel_names{obj.EnabledChannels(k)};
                    enableChannel(obj, obj.iioDev, name, obj.isOutput);
                end
            end
            obj.enabledChannels = true;
            
            % Create the buffers
            if obj.channelCount>0
                status = createBuf(obj);
                if status
                    releaseChanBuffers(obj);
                    cerrmsg(obj,status,['Failed to create buffer for: ' obj.devName]);
                    return
                end
            else
                status = 0;
            end
            
        end
        
    end
    
end

