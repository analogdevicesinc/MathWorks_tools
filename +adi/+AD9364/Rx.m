classdef Rx < adi.AD9361.Rx
    % adi.AD9364.Rx Receive data from the AD9364 transceiver
    %   The adi.AD9361.Rx System object is a signal source that can receive
    %   complex data from the AD9364.
    %
    %   rx = adi.AD9364.Rx;
    %   rx = adi.AD9364.Rx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9364.pdf">AD9364 Datasheet</a>
    %
    %   See also adi.FMComms4.Rx
    
    properties (Nontunable)
        %channelCount channel Count
        %   Number of enabled IQ channels. 2 enables one I and one Q
        %   channel
        channelCount = 2;
    end
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9361.Rx(varargin{:});
        end
        % Check channelCount
        function set.channelCount(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'positive','scalar', 'finite', 'nonnan', 'nonempty','integer','even','>',1,'<=',2}, ...
                '', 'channelCount');
            obj.channelCount = value;
        end
    end
    
end

