classdef Tx < adi.AD9361.Tx
    % adi.AD9363.Tx Transmit data from the AD9364 transceiver
    %   The adi.AD9363.Tx System object is a signal sink that can
    %   transmit complex data from the AD9364.
    %
    %   tx = adi.AD9363.Tx;
    %   tx = adi.AD9363.Tx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9363.pdf">AD9363 Datasheet</a>
    %
    %   See also adi.Pluto.Tx
    
    methods
        %% Constructor
        function obj = Tx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9361.Tx(varargin{:});
        end
    end
    
end

