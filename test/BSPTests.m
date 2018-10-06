classdef BSPTests < BSPTestsBase
    
    methods(TestClassSetup)
        function removeinstalledbsp(~)
            str = 'Analog Devices Board Support Packages';
            ts = matlab.addons.toolbox.installedToolboxes;
            for t = ts
                if contains(t.Name,str)
                    disp('Removing installed BSP');
                    matlab.addons.toolbox.uninstallToolbox(t);
                end
            end
        end
        % Add the necessary files to path
        function addbspfiles(~)
            addpath(genpath('../hdl_wa_bsp'));
        end
    end
    
end
