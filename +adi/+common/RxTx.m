classdef (Abstract) RxTx < matlabshared.libiio.base
    
    properties (Nontunable, Hidden)
        enabledChannels = false;
        ConnectedToDevice = false;
    end
    
    properties (Nontunable, Hidden)
        DataTimeout = 5;
    end
    
    properties (Abstract, Hidden, Constant)
        Type
    end
    
    %% Abstract API Functions
    methods (Abstract, Hidden, Access = protected)
        % Write attributes to device once connected
        setupInit(obj)
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        % Hide unused parameters when in specific modes
        function flag = isInactivePropertyImpl(obj, prop)
            flag = strcmpi(prop,'enIO');
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
                for k=1:obj.channelCount
                    disableChannel(obj, obj.channel_names{k}, obj.isOutput);
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
            for k=1:obj.channelCount
                enableChannel(obj, obj.channel_names{k}, obj.isOutput);
            end
            obj.enabledChannels = true;
            
            % Create the buffers
            status = createBuf(obj);
            if status
                for k=1:obj.channelCount
                    disableChannel(obj, obj.channel_names{k}, obj.isOutput);
                end
                releaseChanBuffers(obj);
                cerrmsg(obj,status,['Failed to create buffer for: ' obj.devName]);
                return
            end
            
        end
        
    end
    
end

