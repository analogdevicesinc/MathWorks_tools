classdef Tx < adi.AD9364.Tx
    % adi.FMComms4.Tx Transmit data from the FMComms4 evaluation board
    %   The adi.FMComms4.Tx System object is a signal sink that can
    %   transmit complex data from the FMComms4.
    %
    %   tx = adi.FMComms4.Tx;
    %   tx = adi.FMComms4.Tx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9364.pdf">AD9364 Datasheet</a>
    %
    %   See also adi.AD9364.Tx
    methods
        %% Constructor
        function obj = Tx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9364.Tx(varargin{:});
        end
    end
    
end

