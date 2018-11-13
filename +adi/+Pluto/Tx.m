classdef Tx < adi.AD9363.Tx
    % adi.Pluto.Tx Transmit data from the Pluto evaluation board
    %   The adi.Pluto.Tx System object is a signal sink that can
    %   transmit complex data from the Pluto.
    %
    %   tx = adi.Pluto.Tx;
    %   tx = adi.Pluto.Tx('uri','192.168.2.1');
    %
    %   <a href="https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/ADALM-PLUTO.html">Product Page</a>
    %
    %   See also adi.AD9363.Tx
    methods
        %% Constructor
        function obj = Tx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9363.Tx(varargin{:});
        end
    end
    
end

