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
        %   Frequencies values in Hz of the four DDS tone generators per
        %   channel. Input is a [2x4] matrix or a [2x8] matrix if four
        %   input channels are enabled.
        DDSFrequencies = [5e5,5e5,5e5,5e5;5e5,5e5,5e5,5e5];
        %DDSScales DDS Scales
        %   Scale of DDS tones in range [0,1].Input is a [2x4] matrix or a
        %   [2x8] matrix if four input channels are enabled.
        DDSScales = [1,0,1,0;0,0,0,0];
        %DDSPhases DDS Phases
        %   Phases of DDS tones in range [0,360000]. Input is a [2x4]
        %   matrix or a [2x8] matrix if four input channels are enabled.
        DDSPhases = [0,0,90000,0;0,0,0,0];
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
    
    methods
        % Check DataSource
        function set.DataSource(obj, value)
            obj.DataSource = value;
            if obj.ConnectedToDevice
                obj.ToggleDDS(strcmp(value,'DDS'));
            end
        end
    end
    
    methods (Hidden, Access=protected)
        
        function ToggleDDS(obj,value)
            chanPtr = getChan(obj,'altvoltage0',true);
            iio_channel_attr_write_bool(obj,chanPtr,'raw',value);
        end
        
        function DDSUpdate(obj)
            obj.ToggleDDS(true);
            for g=1:obj.channelCount/2
                for k=1:4
                    id = sprintf('altvoltage%d',k-1);
                    chanPtr = getChan(obj,id,true);
                    iio_channel_attr_write_double(obj,chanPtr,'frequency',obj.DDSFrequencies(g,k));
                    iio_channel_attr_write_double(obj,chanPtr,'scale',obj.DDSScales(g,k));
                    iio_channel_attr_write_double(obj,chanPtr,'phase',obj.DDSPhases(g,k));
                end
            end
        end
        
    end
    
end

