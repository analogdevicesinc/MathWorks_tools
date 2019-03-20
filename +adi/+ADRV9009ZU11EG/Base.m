classdef (Abstract, Hidden = true) Base < adi.common.Attribute & matlabshared.libiio.base & ...
        matlab.system.mixin.CustomIcon
    %adi.ADRV9009.Base Class
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
    
    properties (Hidden, Constant)
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar 
        %   in samples per second.
        SamplingRate = 245.76e6;
    end
    
    properties
        %CenterFrequency Center Frequency
        %   RF center frequency, specified in Hz as a scalar. The
        %   default is 2.4e9.  This property is tunable.
        CenterFrequencyChipA = 2.4e9;
        %CenterFrequency Center Frequency
        %   RF center frequency, specified in Hz as a scalar. The
        %   default is 2.4e9.  This property is tunable.
        CenterFrequencyChipB = 2.4e9;
    end
    
    properties(Nontunable, Hidden)
        Timeout = Inf;
        kernelBuffersCount = 2;
        dataTypeStr = 'int16';
        phyDevName = 'adrv9009-phy';
        iioDevPHY
    end

    
    methods
        %% Constructor
        function obj = Base(varargin)
            coder.allowpcode('plain');
            obj = obj@matlabshared.libiio.base(varargin{:});
        end
        % Destructor
        function delete(~)
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
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','even','>',1,'<=',8}, ...
                '', 'channelCount');
            obj.channelCount = value;
        end
        % Check CenterFrequencyChipA
        function set.CenterFrequencyChipA(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',70e6,'<=',6e9}, ...
                '', 'CenterFrequencyChipA');
            obj.CenterFrequencyChipA = value;
            if obj.ConnectedToDevice
                id = 'altvoltage0';
                obj.setAttributeLongLong(id,'frequency',value,true);
            end
        end
        % Check CenterFrequencyChipB
        function set.CenterFrequencyChipB(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',70e6,'<=',6e9}, ...
                '', 'CenterFrequencyChipB');
            obj.CenterFrequencyChipB = value;
            if obj.ConnectedToDevice
                id = 'altvoltage0';
                obj.setAttributeLongLong(id,'frequency',value,true);
            end
        end
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
               
        function icon = getIconImpl(obj)
            icon = sprintf(['ADRV9009 ',obj.Type]);
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
            bName = 'ADRV9009';
        end
        
    end
end

