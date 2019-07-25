classdef (Abstract) DDS < matlabshared.libiio.base
    %DDS DDS features
    
    properties (Nontunable)
        %DataSource Data Source
        %   Data source, specified as one of the following:
        %   'DMA' — Specify the host as the source of the data.
        %   'DDS' — Specify the DDS on the radio hardware as the source
        %   of the data. In this case, each channel has two additive tones.
        DataSource = 'DMA';
    end
    
    properties
        %DDSFrequencies DDS Frequencies
        %   Frequencies values in Hz of the DDS tone generators.
        %   For complex data devices the input is a [2xN] matrix where 
        %   N is the available channels on the board. For complex data 
        %   devices this is at most max(EnabledChannels)*2. 
        %   For non-complex data devices this is at most 
        %   max(EnabledChannels). If N < this upper limit, other DDSs 
        %   are not set.
        DDSFrequencies = [5e5,5e5; 5e5,5e5];
        %DDSScales DDS Scales
        %   Scale of DDS tones in range [0,1].
        %   For complex data devices the input is a [2xN] matrix where 
        %   N is the available channels on the board. For complex data 
        %   devices this is at most max(EnabledChannels)*2. 
        %   For non-complex data devices this is at most 
        %   max(EnabledChannels). If N < this upper limit, other DDSs 
        %   are not set.
        DDSScales = [1,0;0,0];
        %DDSPhases DDS Phases
        %   Phases of DDS tones in range [0,360000].
        %   For complex data devices the input is a [2xN] matrix where 
        %   N is the available channels on the board. For complex data 
        %   devices this is at most max(EnabledChannels)*2. 
        %   For non-complex data devices this is at most 
        %   max(EnabledChannels). If N < this upper limit, other DDSs 
        %   are not set.
        DDSPhases = [0,0;0,0];
    end
    
    properties (Nontunable, Logical)
        %EnableCyclicBuffers Enable Cyclic Buffers
        %   Enable Cyclic Buffers, configures transmit buffers to be
        %   cyclic, which makes them continuously repeat
        EnableCyclicBuffers = false;
    end
    
    properties(Constant, Hidden)
        DataSourceSet = matlab.system.StringSet({ ...
            'DMA','DDS'});
    end
    
    properties (Abstract)
        EnabledChannels
    end
    
    properties (Abstract, Hidden, Constant)
       channel_names 
    end
    
    methods
        % Check DataSource
        function set.DataSource(obj, value)
            obj.DataSource = value;
            if obj.ConnectedToDevice
                obj.ToggleDDS(strcmp(value,'DDS'));
            end
        end
        % Check DDSFrequencies
        function set.DDSFrequencies(obj, value)
            s = size(value);
            c1 = s(1) == 2;
            c2 = s(2) > 0;
            c3 = s(2) <= length(obj.channel_names);
            assert(c1 && c2 && c3,...
                sprintf(['DDSFrequencies expected to be size [2xN]',...
                ' where 1<=N<=%d'],...
                length(obj.channel_names)));
            
            obj.DDSFrequencies = value;
            if obj.ConnectedToDevice
                obj.DDSUpdate();
            end
        end
        % Check DDSScales
        function set.DDSScales(obj, value)
            s = size(value);
            c1 = s(1) == 2;
            c2 = s(2) > 0;
            c3 = s(2) <= length(obj.channel_names);
            assert(c1 && c2 && c3,...
                sprintf(['DDSFrequencies expected to be size [2xN]',...
                ' where 1<=N<=%d'],...
                length(obj.channel_names)));
            assert(~any(value>1,'all'),'DDSScales cannot > 1');
            assert(~any(value<0,'all'),'DDSScales cannot < 0');
            
            obj.DDSScales = value;
            if obj.ConnectedToDevice
                obj.DDSUpdate();
            end
        end
        % Check DDSScales
        function set.DDSPhases(obj, value)
            s = size(value);
            c1 = s(1) == 2;
            c2 = s(2) > 0;
            c3 = s(2) <= length(obj.channel_names);
            assert(c1 && c2 && c3,...
                sprintf(['DDSFrequencies expected to be size [2xN]',...
                ' where 1<=N<=%d'],...
                length(obj.channel_names)));
            assert(~any(value>360000,'all'),'DDSPhases cannot > 1');
            assert(~any(value<0,'all'),'DDSPhases cannot < 0');
            
            obj.DDSPhases = value;
            if obj.ConnectedToDevice
                obj.DDSUpdate();
            end
        end
        
    end
    
    methods (Hidden, Access=protected)
        
        function ToggleDDS(obj,value)
            chanPtr = getChan(obj,obj.iioDev,'altvoltage0',true);
            iio_channel_attr_write_bool(obj,chanPtr,'raw',value);
        end
                
        function DDSUpdate(obj)
            obj.ToggleDDS(true);

            %% Set frequencies
            s = size(obj.DDSFrequencies);
            indx = 0;
            for channel=1:s(2)
                for toneIdx = 1:2
                    id = sprintf('altvoltage%d',indx);
                    indx = indx + 1;
                    chanPtr = getChan(obj,obj.iioDev,id,true);
                    iio_channel_attr_write_double(obj,chanPtr,'frequency',obj.DDSFrequencies(toneIdx,channel));
                end
            end
            %% Set scales
            s = size(obj.DDSScales);
            indx = 0;
            for channel=1:s(2)
                for toneIdx = 1:2
                    id = sprintf('altvoltage%d',indx);
                    indx = indx + 1;
                    chanPtr = getChan(obj,obj.iioDev,id,true);
                    iio_channel_attr_write_double(obj,chanPtr,'scale',obj.DDSScales(toneIdx,channel));
                end
            end
            %% Set phases
            s = size(obj.DDSPhases);
            indx = 0;
            for channel=1:s(2)
                for toneIdx = 1:2
                    id = sprintf('altvoltage%d',indx);
                    indx = indx + 1;
                    chanPtr = getChan(obj,obj.iioDev,id,true);
                    iio_channel_attr_write_double(obj,chanPtr,'phase',obj.DDSPhases(toneIdx,channel));
                end
            end
        end
        
    end
    
end

