classdef Version
    %Version
    %   BSP Version information
    properties(Constant)
        HDL = 'hdl_2018_r1';
        Vivado = '2017.4.1';
        MATLAB = 'R2018b';
        Release = '18.2';
    end
    properties(Dependent)
        VivadoShort
    end
    
    methods
        function value = get.VivadoShort(obj)
            value = obj.Vivado(1:6); 
        end
    end
end

