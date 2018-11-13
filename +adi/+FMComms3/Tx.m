classdef Tx < adi.AD9361.Tx
    % adi.FMComms3.Tx Transmit data from the FMComms3 evaluation platform
    %   The adi.FMComms3.Tx System object is a signal source that can 
    %   send complex data to the FMComms2.
    %
    %   tx = adi.FMComms3.Tx;
    %   tx = adi.FMComms3.Tx('uri','192.168.2.1');
    %
    %   <a href="https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/EVAL-AD-FMCOMMS3.html">Product Page</a>
    %
    %   See also adi.AD9361.Tx
    methods
        %% Constructor
        function obj = Tx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9361.Tx(varargin{:});
        end
    end
    
end

