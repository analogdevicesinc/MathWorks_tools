classdef Tx < adi.AD9144.Tx
    % adi.DAQ2.Tx Transmit data from the DAQ2 evaluation platform
    %   The adi.DAQ2.Tx System object is a signal source that can 
    %   send complex data to the DAQ2.
    %
    %   tx = adi.DAQ2.Tx;
    %   tx = adi.DAQ2.Tx('uri','192.168.2.1');
    %
    %   <a href="https://wiki.analog.com/resources/eval/user-guides/ad-fmcdaq2-ebz">User Guide</a>
    %
    %   See also adi.AD9144.Tx, adi.DAQ2.Rx
    methods
        %% Constructor
        function obj = Tx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9144.Tx(varargin{:});
        end
    end
    
end

