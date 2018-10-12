classdef Rx < adi.AD9364.Rx
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9364.Rx(varargin{:});
        end
    end
    
end

