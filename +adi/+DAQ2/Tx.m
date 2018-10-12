classdef Tx < adi.AD9144.Tx
    
    methods
        %% Constructor
        function obj = Tx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9144.Tx(varargin{:});
        end
    end
    
end

