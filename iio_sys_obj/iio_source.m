classdef iio_source < iio_sys_obj
    % iio_source Data Source block for IIO devices
    
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
        function obj = iio_source(varargin)
            % Support name-value pair arguments when constructing the object.
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access = protected)
        %% Common functions
        
        function setupImpl(obj,u)
            % Set the inherited class members values
            obj.out_ch_size = obj.ch_size;
            obj.in_ch_no = 0;
            obj.out_ch_no = obj.ch_no;
            obj.ip_address = obj.src_ip_address;
            obj.dev_name = obj.src_dev_name;
            
            % Call the superclass method
            setupImpl@iio_sys_obj(obj);
        end
        
        function num = getNumInputsImpl(~)
            % Get number of inputs.
            num = 0;
        end
        
        function num = getNumOutputsImpl(obj)
            % Get number of outputs.
            num = obj.ch_no;
        end
        
        function varargout = isOutputFixedSizeImpl(obj)
            % Get outputs fixed size.
            varargout = cell(1, getNumOutputs(obj));
            for i = 1:getNumOutputs(obj)
                varargout{i} = true;
            end            
        end
        
        function varargout = getOutputDataTypeImpl(obj)
            % Get outputs data types.
            varargout = cell(1, getNumOutputs(obj));
            for i = 1:getNumOutputs(obj)
                varargout{i} = 'double';
            end
        end
         
        function varargout = isOutputComplexImpl(obj)
            % Get outputs data types.
            varargout = cell(1, getNumOutputs(obj));
            for i = 1:getNumOutputs(obj)
                varargout{i} = false;
            end
        end
        
        function varargout = getOutputSizeImpl(obj)
            % Implement if input size does not match with output size.
            varargout = cell(1, getNumOutputs(obj));
            for i = 1:getNumOutputs(obj)
                varargout{i} = [obj.ch_size 1];
            end
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
