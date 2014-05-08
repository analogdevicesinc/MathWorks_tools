classdef iio_sys_obj < matlab.System & matlab.system.mixin.Propagates ...
        & matlab.system.mixin.CustomIcon
    % iio_sys_obj Data Source block for IIO devices
    
    properties
        % Public, tunable properties.
    end
    
    properties (Nontunable)
        % Public, non-tunable properties.
        
        % ip_address IP address
        ip_address = '192.168.1.137';
        
        %dev_name Device name
        dev_name = 'cf-ad9361-lpc';
        
        %ch_size Channel size [samples]
        ch_size = 8192;
        
        %ch_no Number of active channels
        ch_no = 4;
    end
    
    properties (Access = private)
        % Private class properties.
        libname = 'libiio';
        hname = 'iio.h';
        iio_ctx = {};
        iio_dev = {};
        iio_buffer = {};
        iio_channel = {};
        iio_buf_size = 8192;
    end
    
    properties (DiscreteState)
    end
    
    methods
        % Constructor
        function obj = iio_sys_obj(varargin)
            % Support name-value pair arguments when constructing the object.
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access = protected)
        %% Common functions
        function setupImpl(obj,u)
            % Implement tasks that need to be performed only once,
            % such as pre-computed constants.
            
            [notfound, warnings]= loadlibrary(obj.libname, obj.hname);
            
            if(libisloaded(obj.libname))
                % Create network context
                obj.iio_ctx = calllib(obj.libname, 'iio_create_network_context', obj.ip_address);
                
                % Get the number of devices
                try
                    nb_devices = calllib(obj.libname, 'iio_context_get_devices_count', obj.iio_ctx);
                catch
                    obj.iio_ctx = {};
                    unloadlibrary(obj.libname);
                    msgbox('Could not connect to the IIO server!', 'Error','error');
                end
                
                % If no devices are present unload the library and exit
                if(nb_devices == 0)
                    calllib(obj.libname, 'iio_context_destroy', obj.iio_ctx);
                    obj.iio_ctx = {};
                    unloadlibrary(obj.libname);
                    msgbox('No devices were detected in the system!', 'Error','error');
                end
                
                % Detect if the targeted device is installed and activate
                % the number of desired channels
                for i = 0 : nb_devices-1
                    dev = calllib(obj.libname, 'iio_context_get_device', obj.iio_ctx, i);
                    name = calllib(obj.libname, 'iio_device_get_name', dev);
                    if(strcmp(name, obj.dev_name))
                        obj.iio_dev = dev;
                        nb_channels = calllib(obj.libname, 'iio_device_get_channels_count', dev);
                        if(obj.ch_no <= nb_channels)
                            nb_channels = obj.ch_no;
                        end
                        for j = 0 : nb_channels-1
                            obj.iio_channel{j+1} = calllib(obj.libname, 'iio_device_get_channel', dev, j);
                            calllib(obj.libname, 'iio_channel_enable', obj.iio_channel{j+1});
                        end
                        obj.iio_buf_size = obj.ch_size * nb_channels;
                        obj.iio_buffer = calllib(obj.libname, 'iio_device_create_buffer', dev, obj.iio_buf_size);
                        return;
                    end                
                    clear dev;
                end
                
                % The target device was not detected, display an error and
                % unload the library
                calllib(obj.libname, 'iio_context_destroy', obj.iio_ctx);
                obj.iio_ctx = {};
                unloadlibrary(obj.libname);
                msgbox('Could not find target device!', 'Error','error');
            else
                % Could not load library
                msgbox('Could not load library!', 'Error','error');
            end
        end
        
        function releaseImpl(obj)
            % Release any resources used by the system object            
            if(libisloaded(obj.libname))
                calllib(obj.libname, 'iio_buffer_destroy', obj.iio_buffer);
                calllib(obj.libname, 'iio_context_destroy', obj.iio_ctx);
                obj.iio_buffer = {};
                obj.iio_channel = {};
                obj.iio_dev = {};
                obj.iio_ctx = {};
                unloadlibrary(obj.libname);
            end
        end
        
        function varargout = stepImpl(obj)
            % Implement data capture flow.
            varargout = cell(1, getNumOutputs(obj));
            if(libisloaded(obj.libname))
                calllib(obj.libname, 'iio_buffer_refill', obj.iio_buffer);
                data = calllib(obj.libname, 'iio_buffer_first', obj.iio_buffer, obj.iio_channel{1});
                setdatatype(data, 'int16Ptr', obj.iio_buf_size);
                for i = 1:getNumOutputs(obj)
                    varargout{i} = double(data.Value(i:getNumOutputs(obj):end));
                end
            else
                for i = 1:getNumOutputs(obj)
                    varargout{i} = zeros(obj.ch_size, 1);
                end
            end
        end
        
        function resetImpl(obj)
            % Initialize discrete-state properties.
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
        
        %% Backup/restore functions
        function s = saveObjectImpl(obj)
            % Save private, protected, or state properties in a
            % structure s. This is necessary to support Simulink
            % features, such as SimState.
        end
        
        function loadObjectImpl(obj,s,wasLocked)
            % Read private, protected, or state properties from
            % the structure s and assign it to the object obj.
        end
        
        %% Simulink functions
        function z = getDiscreteStateImpl(obj)
            % Return structure of states with field names as
            % DiscreteState properties.
            z = struct([]);
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
