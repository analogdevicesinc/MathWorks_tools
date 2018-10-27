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
%                 disableChannel(obj, obj.channel, obj.isOutput);
                releaseChanBuffers(obj);
                cerrmsg(obj,status,['Failed to create buffer for: ' obj.devName]);
                return
            end
            
        end
        
    end
    
end

