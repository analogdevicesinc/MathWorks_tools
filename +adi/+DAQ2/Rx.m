classdef Rx < adi.AD9680.Rx
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9680.Rx(varargin{:});
        end
    end
    
end

