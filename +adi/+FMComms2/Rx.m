classdef Rx < adi.AD9361.Rx
    % adi.FMComms2.Rx Receive data from the FMComms2 evaluation platform
    %   The adi.FMComms2.Rx System object is a signal source that can 
    %   receive complex data from the FMComms2.
    %
    %   rx = adi.FMComms2.Rx;
    %   rx = adi.FMComms2.Rx('uri','192.168.2.1');
    %
    %   <a href="https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/EVAL-AD-FMCOMMS2.html">Product Page</a>
    %
    %   See also adi.AD9361.Rx
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9361.Rx(varargin{:});
        end
    end
    
end

