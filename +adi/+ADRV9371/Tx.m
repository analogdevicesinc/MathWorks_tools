classdef Tx < adi.AD9371.Tx
    % adi.ADRV9371.Tx Transmit data to the ADRV9371 evaluation platform
    %   The adi.ADRV9371.Tx System object is a signal sink that can send
    %   complex data to the ADRV9371.
    %
    %   tx = adi.AD9371.Tx;
    %   tx = adi.AD9371.Tx('uri','192.168.2.1');
    %
    %   <a href="https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/EVAL-ADRV9371.html">Product Page</a>    
    %
    %   See also adi.AD9371.Tx
    methods
        %% Constructor
        function obj = Tx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9371.Tx(varargin{:});
        end
    end
    
end

