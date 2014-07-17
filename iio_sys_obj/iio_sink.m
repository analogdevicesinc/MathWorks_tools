classdef iio_sink < iio_sys_obj
    % iio_sink Data Sink block for IIO devices
    
    properties
        % Public, tunable properties.
    end
    
    properties (Nontunable)
        % Public, non-tunable properties.
        
        % src_ip_address IP address
        src_ip_address = '';
        
        %src_dev_name Device name
        src_dev_name = '';
        
        %ch_size Channel size [samples]
        ch_size = 8192;
        
        %ch_no Number of active channels
        ch_no = 1;        
      end
    
    properties (Access = private)
        % Private class properties.
    end
    
    properties (DiscreteState)
    end
    
    methods
        % Constructor
        function obj = iio_sink(varargin)
            % Support name-value pair arguments when constructing the object.
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access = protected)
        %% Common functions
        
        function setupImpl(obj, varargin)
            % Set the inherited class members values
            obj.in_ch_size = obj.ch_size;
            obj.in_ch_no = obj.ch_no;
            obj.out_ch_no = 0;
            obj.ip_address = obj.src_ip_address;
            obj.dev_name = obj.src_dev_name;
            
            % Call the superclass method
            setupImpl@iio_sys_obj(obj);
        end
        
        function num = getNumInputsImpl(obj)
            % Get number of inputs.
            num = obj.ch_no;
        end
        
        function num = getNumOutputsImpl(~)
            % Get number of outputs.
            num = 0;
        end
        
        function icon = getIconImpl(obj)
            % Define a string as the icon for the System block in Simulink.
            icon = mfilename('class');
        end
        
    end
    
    methods(Static, Access = protected)
        %% Simulink customization functions
        function header = getHeaderImpl(obj)
            % Define header for the System block dialog box.
            header = matlab.system.display.Header(mfilename('class'));
        end
        
        function group = getPropertyGroupsImpl(obj)
            % Define section for properties in System block dialog box.
            group = matlab.system.display.Section(mfilename('class'));
        end
    end
end
