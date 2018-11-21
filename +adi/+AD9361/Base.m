classdef (Abstract, Hidden = true) Base < adi.common.Attribute & matlabshared.libiio.base & ...
        matlab.system.mixin.CustomIcon
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
    
    properties (Abstract)
        %CenterFrequency Center Frequency
        %   RF center frequency, specified in Hz as a scalar. The
        %   default is 2.4e9.  This property is tunable.
        CenterFrequency
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar
        %   from 65105 to 61.44e6 samples per second.
        SamplingRate
        %RFBandwidth RF Bandwidth
        %   RF Bandwidth of front-end analog filter in Hz, specified as a
        %   scalar from 200 kHz to 56 MHz.
        RFBandwidth
    end
    
    properties(Nontunable, Hidden)
        Timeout = Inf;
        kernelBuffersCount = 2;
        dataTypeStr = 'int16';
        phyDevName = 'ad9361-phy';
        iioDevPHY
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
            if isa(obj,'adi.AD9364.Rx') || isa(obj,'adi.AD9364.Tx')
                validateattributes( value, { 'double','single' }, ...
                    { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','even','>',1,'<=',2}, ...
                    '', 'channelCount');
            else
                validateattributes( value, { 'double','single' }, ...
                    { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','even','>',1,'<=',4}, ...
                    '', 'channelCount');
            end
            obj.channelCount = value;
        end
        
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        function icon = getIconImpl(obj)
            icon = sprintf(['AD9361 ',obj.Type]);
        end
        
        function setupLibad9361(obj)
            libName = 'libad9361';
            ad9361wrapperh = 'ad9361-wrapper.h';
            ad9361h = 'ad9361.h';
            fp = fileparts(which(ad9361h));
            loadlibraryArgs = {ad9361wrapperh,'includepath',fp,'addheader',ad9361h};
            if ~libisloaded(libName)
                msgID = 'MATLAB:loadlibrary:StructTypeExists';
                warnStruct = warning('off',msgID);
                [~, ~] = loadlibrary(libName, loadlibraryArgs{:});
                warning(warnStruct);
            end
            obj.iioDevPHY = calllib('libiio', 'iio_context_find_device',obj.iioCtx,'ad9361-phy');
        end
        
        function teardownLibad9361(~)
            libName = 'libad9361';
            if libisloaded(libName)
                unloadlibrary(libName);
            end
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

