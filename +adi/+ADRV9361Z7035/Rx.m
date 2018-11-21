classdef Rx < adi.AD9361.Rx
    % adi.ADRV9361Z7035.Rx Receive data from the ADRV9361Z7035 SOM
    %   The adi.ADRV9361Z7035.Rx System object is a signal source that can 
    %   receive complex data from the ADRV9361Z7035.
    %
    %   rx = adi.ADRV9361Z7035.Rx;
    %   rx = adi.ADRV9361Z7035.Rx('uri','192.168.2.1');
    %
    %   <a href="https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/adrv9361-z7035.html">Product Page</a>
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

