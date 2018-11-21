classdef Rx < adi.AD9363.Rx
    % adi.Pluto.Tx Transmit data from the Pluto evaluation platform
    %   The adi.Pluto.Tx System object is a signal source that can 
    %   send complex data to the Pluto.
    %
    %   tx = adi.Pluto.Tx;
    %   tx = adi.Pluto.Tx('uri','192.168.2.1');
    %
    %   <a href="https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/ADALM-PLUTO.html">Product Page</a>
    %
    %   See also adi.AD9363.Tx    
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9363.Rx(varargin{:});
        end
    end
    
end

