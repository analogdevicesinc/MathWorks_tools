classdef Rx < adi.AD9361.Rx
    % adi.AD9363.Rx Receive data from the AD9363 transceiver
    %   The adi.AD9363.Rx System object is a signal source that can receive
    %   complex data from the AD9364.
    %
    %   rx = adi.AD9363.Rx;
    %   rx = adi.AD9363.Rx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9363.pdf">AD9363 Datasheet</a>
    %
    %   See also adi.Pluto.Rx
    
    properties
        %CenterFrequency Center Frequency
        %   RF center frequency, specified in Hz as a scalar. The
        %   default is 2.4e9.  This property is tunable.
        CenterFrequency = 2.4e9;
        %SamplingRate Sampling Rate
        %   Baseband sampling rate in Hz, specified as a scalar 
        %   from 65105 to 20e6 samples per second.
        SamplingRate = 3e6;
        %RFBandwidth RF Bandwidth
        %   RF Bandwidth of front-end analog filter in Hz, specified as a
        %   scalar from 200 kHz to 20 MHz.
        RFBandwidth = 3e6;
    end
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9361.Rx(varargin{:});
        end
        % Check CenterFrequency
        function set.CenterFrequency(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',325e6,'<=',3.8e9}, ...
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
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',200e3,'<=',20e6}, ...
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
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',2083333,'<=',20e6}, ...
                '', 'SamplesPerFrame');
            obj.SamplingRate = value;
            if obj.ConnectedToDevice
                id = 'voltage0';
                obj.setAttributeLongLong(id,'sampling_frequency',value,true);
            end
        end
    end
    
end

