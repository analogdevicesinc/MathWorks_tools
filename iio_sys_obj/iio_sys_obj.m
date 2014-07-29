classdef iio_sys_obj < matlab.System & matlab.system.mixin.Propagates ...
        & matlab.system.mixin.CustomIcon
    % iio_sys_obj System Object block for IIO devices
    
    properties
        % Public, tunable properties.
    end
    
    properties (Access = protected)
        % Protected class properties.
        
        % ip_address IP address
        ip_address = '';
        
        %dev_name Device name
        dev_name = '';
        
        %in_ch_size Input channel size [samples]
        in_ch_size = 8192;
        
        %in_ch_no Number of active input channels
        in_ch_no = 1;
        
        %out_ch_size Output channel size [samples]
        out_ch_size = 8192;
        
        %out_ch_no Number of active output channels
        out_ch_no = 1;
        
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
        iio_scan_elements_no = 0;
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
    
    methods (Static, Access = private)
        %% Static functions
        function out = modInstanceCnt(val)
            % Manages the number of object instances to hadle proper DLL
            % unloading
            persistent instance_cnt;
            if isempty(instance_cnt)
                instance_cnt = 0;
            end
            instance_cnt = instance_cnt + val;
            out = instance_cnt;
        end
    end
    
    methods (Access = protected)
        %% Common functions
        function setupImpl(obj,~)
            % Implement tasks that need to be performed only once,
            % such as pre-computed constants.
            
            iio_sys_obj.modInstanceCnt(1);
            
            [notfound, warnings]= loadlibrary(obj.libname, obj.hname);
            
            if(libisloaded(obj.libname))
                % Create network context
                obj.iio_ctx = calllib(obj.libname, 'iio_create_network_context', obj.ip_address);
                
                % Check if the network context is valid
                ctx_valid = calllib(obj.libname, 'iio_context_valid', obj.iio_ctx);
                if(ctx_valid < 0)
                    obj.iio_ctx = {};
                    unloadlibrary(obj.libname);
                    msgbox('Could not connect to the IIO server!', 'Error','error');
                    return;
                end
                
                % Get the number of devices
                nb_devices = calllib(obj.libname, 'iio_context_get_devices_count', obj.iio_ctx);
                
                % If no devices are present unload the library and exit
                if(nb_devices == 0)
                    calllib(obj.libname, 'iio_context_destroy', obj.iio_ctx);
                    obj.iio_ctx = {};
                    unloadlibrary(obj.libname);
                    msgbox('No devices were detected in the system!', 'Error','error');
                    return;
                end
                
                % Detect if the targeted device is installed and activate
                % the number of desired channels
                for i = 0 : nb_devices-1
                    dev = calllib(obj.libname, 'iio_context_get_device', obj.iio_ctx, i);
                    name = calllib(obj.libname, 'iio_device_get_name', dev);
                    if(strcmp(name, obj.dev_name))
                        % Get the number of channels that the device has                        
                        obj.iio_dev = dev;
                        nb_channels = calllib(obj.libname, 'iio_device_get_channels_count', dev);
                        if(nb_channels == 0)
                            calllib(obj.libname, 'iio_context_destroy', obj.iio_ctx);
                            obj.iio_ctx = {};
                            unloadlibrary(obj.libname);
                            msgbox('The seleted device does not have any channels!', 'Error','error');
                            return;
                        end
                        
                        % Enable the system object input channels
                        if(obj.in_ch_no ~= 0)                            
                            % Check if the device has output channels. The
                            % logic here assumes that a device can have
                            % only input or only output channels
                            obj.iio_channel{1} = calllib(obj.libname, 'iio_device_get_channel', dev, 0);
                            is_output = calllib(obj.libname, 'iio_channel_is_output', obj.iio_channel{1});                            
                            if(is_output == 0)
                                calllib(obj.libname, 'iio_context_destroy', obj.iio_ctx);
                                obj.iio_ctx = {};
                                unloadlibrary(obj.libname);
                                msgbox('The seleted device does not have output channels!', 'Error','error');
                                return;
                            end
                            % Enable all the channels
                            for j = 0 : nb_channels-1
                                obj.iio_channel{j+1} = calllib(obj.libname, 'iio_device_get_channel', dev, j);
                                calllib(obj.libname, 'iio_channel_enable', obj.iio_channel{j+1});
                                is_scan_element = calllib(obj.libname, 'iio_channel_is_scan_element', obj.iio_channel{j+1});
                                if(is_scan_element == 1)
                                    obj.iio_scan_elements_no = obj.iio_scan_elements_no + 1;
                                end
                            end
                            
                            % Create the IIO buffer used to read / write data
                            obj.iio_buf_size = obj.in_ch_size * obj.in_ch_no;
                            obj.iio_buffer = calllib(obj.libname, 'iio_device_create_buffer', dev,...
                                                     obj.in_ch_size * (obj.in_ch_no / obj.iio_scan_elements_no), 1);
                        end
                        
                        % Enable the system object output channels
                        if(obj.out_ch_no ~= 0)                            
                            % Check if the device has input channels. The
                            % logic here assumes that a device can have
                            % only input or only output channels
                            obj.iio_channel{1} = calllib(obj.libname, 'iio_device_get_channel', dev, 0);
                            is_output = calllib(obj.libname, 'iio_channel_is_output', obj.iio_channel{1});                            
                            if(is_output == 1)
                                calllib(obj.libname, 'iio_context_destroy', obj.iio_ctx);
                                obj.iio_ctx = {};
                                unloadlibrary(obj.libname);
                                msgbox('The seleted device does not have input channels!', 'Error','error');
                                return;
                            end
                            % Enable the channels
                            if(obj.out_ch_no <= nb_channels)
                                nb_channels = obj.out_ch_no;
                            end
                            for j = 0 : nb_channels-1
                                obj.iio_channel{j+1} = calllib(obj.libname, 'iio_device_get_channel', dev, j);
                                calllib(obj.libname, 'iio_channel_enable', obj.iio_channel{j+1});
                            end
                            for j = nb_channels:obj.out_ch_no-1
                                obj.iio_channel{j+1} = calllib(obj.libname, 'iio_device_get_channel', dev, j);
                                calllib(obj.libname, 'iio_channel_disable', obj.iio_channel{j+1});
                            end
                            % Create the IIO buffer used to read / write data
                            obj.iio_buf_size = obj.out_ch_size * nb_channels;
                            obj.iio_buffer = calllib(obj.libname, 'iio_device_create_buffer', dev, obj.iio_buf_size, 0);
                        end                 
                        
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
                instCnt = iio_sys_obj.modInstanceCnt(-1);
                if(instCnt == 0)
                    unloadlibrary(obj.libname);
                end
            end
        end
        
        function varargout = stepImpl(obj, varargin)
            % Implement data capture flow.
            if(getNumOutputs(obj) ~= 0)
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
                        varargout{i} = zeros(obj.out_ch_size, 1);
                    end
                end
            end
                
            % Implement data transmit flow.
            if(getNumInputs(obj) ~= 0)
                if(libisloaded(obj.libname))
                    data = calllib(obj.libname, 'iio_buffer_start', obj.iio_buffer);
                    setdatatype(data, 'int16Ptr', obj.iio_buf_size);
                    for i = 1:getNumInputs(obj)
                        data.Value(i:getNumInputs(obj):obj.iio_buf_size) = int16(varargin{i});
                    end
                    calllib(obj.libname, 'iio_buffer_push', obj.iio_buffer);
                end
            end
        end
        
        function resetImpl(obj)
            % Initialize discrete-state properties.
        end
        
        function num = getNumInputsImpl(obj)
            % Get number of inputs.
            num = obj.in_ch_no;
        end
        
        function num = getNumOutputsImpl(obj)
            % Get number of outputs.
            num = obj.out_ch_no;
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
    end
end
