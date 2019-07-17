classdef BSPInstallerTests < BSPTestsBase
    properties
        installed = [];
    end
    
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
        function installBSP(obj)
            %system('wget https://github.com/analogdevicesinc/MathWorks_tools/releases/download/v18.1.0/AnalogDevicesBSP_v18.1.0.mltbx');
            %system('rm *.mltbx');
            %system('curl -s https://api.github.com/repos/analogdevicesinc/MathWorks_tools/releases/latest | grep browser_download_url | cut -d "\"" -f 4 | wget --no-check-certificate -i -');
            %tbname = 'AnalogDevicesBSP_v18.1.mltbx';
            disp('BSP Installer tests setup called');           
            files = dir('.');
            for file = 1:length(files)
                fn = files(file).name;
                try
                    if strcmpi(fn(end-5:end),'.mltbx') && ~contains(fn,'examples')
                        tbname = fn;
                        break
                    end
                catch
                    continue;
                end
            end
            disp('BSP Installer tests setup called');
            disp(['Found: ',tbname]);
            obj.installed = matlab.addons.toolbox.installToolbox(tbname);
            obj.installed
            disp("Installed");
        end
    end
    
    methods(TestClassTeardown)
        function uninstallBSP(obj)
            matlab.addons.toolbox.uninstallToolbox(obj.installed);
        end
    end
    
end
