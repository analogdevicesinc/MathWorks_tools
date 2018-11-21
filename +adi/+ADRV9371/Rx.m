classdef Rx < adi.AD9371.Rx
    % adi.ADRV9371.Rx Receive data from the ADRV9371 evaluation platform
    %   The adi.ADRV9371.Rx System object is a signal source that can receive
    %   complex data from the ADRV9371.
    %
    %   rx = adi.AD9371.Rx;
    %   rx = adi.AD9371.Rx('uri','192.168.2.1');
    %
    %   <a href="https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/EVAL-ADRV9371.html">Product Page</a>    
    %
    %   See also adi.AD9371.Rx
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9371.Rx(varargin{:});
        end
    end
    
end

