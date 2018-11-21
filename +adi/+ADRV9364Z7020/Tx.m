classdef Tx < adi.AD9364.Tx
    % adi.ADRV9364Z7020.Tx Transmit data from the ADRV9364Z7020 SOM
    %   The adi.ADRV9364Z7020.Tx System object is a signal sink that can
    %   transmit complex data from the FMComms4.
    %
    %   tx = adi.ADRV9364Z7020.Tx;
    %   tx = adi.ADRV9364Z7020.Tx('uri','192.168.2.1');
    %
    %   <a href="https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/adrv9364-z7020.html">Product Page</a>
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

