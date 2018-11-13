classdef Rx < adi.AD9364.Rx
    % adi.FMComms4.Tx Transmit data from the FMComms4 evaluation platform
    %   The adi.FMComms4.Tx System object is a signal source that can 
    %   send complex data to the FMComms4.
    %
    %   tx = adi.FMComms4.Tx;
    %   tx = adi.FMComms4.Tx('uri','192.168.2.1');
    %
    %   <a href="https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/EVAL-AD-FMCOMMS4.html">Product Page</a>
    %
    %   See also adi.AD9364.Tx
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9364.Rx(varargin{:});
        end
    end
    
end

