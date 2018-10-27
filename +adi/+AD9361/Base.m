classdef (Abstract, Hidden = true) Base < matlabshared.libiio.base & ...
        matlab.system.mixin.CustomIcon & matlab.system.mixin.SampleTime
    %adi.AD9361.Base Class
    %   This class contains shared parameters and methods between TX and RX
    %   classes
    properties (Nontunable)
        %SamplesPerFrame Samples Per Frame
        %   Number of samples per frame, specified as an even positive
        %   integer from 2 to 16,777,216. Using values less than 3660 can
        %   yield poor performance.
        SamplesPerFrame = 2^15;
        %channelCount channel Count
        %   Number of enabled IQ channels. 2 enables one I and one Q
        %   channel
        channelCount = 2;
    end
    
    properties
        %CenterFrequency Center Frequency
        %   RF center frequency, specified in Hz as a scalar. The
        %   default is 2.4e9.  This property is tunable.
        CenterFrequency = 2.4e9;
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar 
        %   from 65105 to 61.44e6 samples per second.
        SamplingRate = 3e6;
        %RFBandwidth RF Bandwidth
        %   RF Bandwidth of front-end analog filter in Hz, specified as a
        %   scalar from 200 kHz to 56 MHz.
        RFBandwidth = 3e6;
    end
    
    properties(Nontunable, Hidden)
        Timeout = Inf;
        kernelBuffersCount = 2;
        dataTypeStr = 'int16';
        phyDevName = 'ad9361-phy';
        iioDevPHY
        Libad9361IncludePathUnix = '/usr/local/include';
        Libad9361LibPathUnix = '/usr/local/lib';
        Libad9361IncludePathWindows = 'C:\Windows\System32';
        Libad9361LibPathWindows = 'C:\Windows\System32';
    end

    
    methods
        %% Constructor
        function obj = Base(varargin)
            coder.allowpcode('plain');
            obj = obj@matlabshared.libiio.base(varargin{:});
        end
        % Destructor
        function delete(obj)
           teardownLibad9361(obj);
        end
        % Check SamplesPerFrame
        function set.SamplesPerFrame(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>',0,'<=',2^20}, ...
                '', 'SamplesPerFrame');
            obj.SamplesPerFrame = value;
        end
        % Check channelCount
        function set.channelCount(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','even','>',1,'<=',4}, ...
                '', 'channelCount');
            obj.channelCount = value;
        end
        % Check CenterFrequency
        function set.CenterFrequency(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',70e6,'<=',6e9}, ...
                '', 'CenterFrequency');
            obj.CenterFrequency = value;
            if obj.ConnectedToDevice
                id = sprintf('altvoltage%d',strcmp(obj.Type,'Tx'));
                obj.setAttributeLongLong(id,'frequency',value,true);
            end
        end
        % Check CenterFrequency
        function set.RFBandwidth(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',200e3,'<=',56e6}, ...
                '', 'RFBandwidth');
            obj.RFBandwidth = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeLongLong(id,'rf_bandwidth',value,strcmp(obj.Type,'Tx'));
            end
        end
        % Check SampleRate
        function set.SamplingRate(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',2083333,'<=',61.44e6}, ...
                '', 'SamplesPerFrame');
            obj.SamplingRate = value;
            if obj.ConnectedToDevice
                if libisloaded('libad9361')
                    calllib('libad9361','ad9361_set_bb_rate',obj.iioDevPHY,int32(value)); %#ok<MCSUP>
                else
                    id = 'voltage0';
                    obj.setAttributeLongLong(id,'sampling_frequency',value,true);
                end
            end
        end
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        function sts = getSampleTimeImpl(obj)
            sts = createSampleTime(obj,'Type','Discrete',...
                'SampleTime',obj.SamplesPerFrame/obj.SamplingRate);
        end
        
        function icon = getIconImpl(obj)
            icon = sprintf(['AD9361 ',obj.Type]);
        end
        
        function setupLibad9361(obj)
            libName = 'libad9361';
            if isunix
                hfile = fullfile(obj.Libad9361IncludePathUnix ,'ad9361-wrapper.h');
                loadlibraryArgs = {hfile,'includepath',obj.Libad9361IncludePathUnix,'addheader','ad9361.h'};
            else
                hfile = fullfile(obj.Libad9361IncludePathWindows,'ad9361-wrapper.h');
                loadlibraryArgs = {hfile,'includepath',obj.Libad9361IncludePathWindows,'addheader','ad9361.h'};
            end
            if ~libisloaded(libName)
                [~, ~] = loadlibrary(libName, loadlibraryArgs{:});
            end
            obj.iioDevPHY = calllib('libiio', 'iio_context_find_device',obj.iioCtx,'ad9361-phy');
        end
        
        function teardownLibad9361(~)
            libName = 'libad9361';
            if libisloaded(libName)
                unloadlibrary(libName);
            end
        end
        
        function setAttributeLongLong(obj,id,attr,value,output)
            phydev = getDev(obj, obj.phyDevName);
            chanPtr = iio_device_find_channel(obj,phydev,id,output);%FIXME (INVERSION)
            status = cPtrCheck(obj,chanPtr);
            cstatus(obj,status,['Channel: ' id ' not found']);
            iio_channel_attr_write_longlong(obj,chanPtr,attr,value);
        end
        
        function setAttributeBool(obj,id,attr,value,output)
            phydev = getDev(obj, obj.phyDevName);
            chanPtr = iio_device_find_channel(obj,phydev,id,output);%FIXME (INVERSION)
            status = cPtrCheck(obj,chanPtr);
            cstatus(obj,status,['Channel: ' id ' not found']);
            iio_channel_attr_write_bool(obj,chanPtr,attr,value);
        end
        
        function setAttributeRAW(obj,id,attr,value,output)
            phydev = getDev(obj, obj.phyDevName);
            chanPtr = iio_device_find_channel(obj,phydev,id,output);%FIXME (INVERSION)
            status = cPtrCheck(obj,chanPtr);
            cstatus(obj,status,['Channel: ' id ' not found']);
            iio_channel_attr_write(obj,chanPtr,attr,value);
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
            bName = 'AD9361';
        end
        
    end
end

