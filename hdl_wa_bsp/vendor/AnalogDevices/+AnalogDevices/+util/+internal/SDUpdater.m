classdef SDUpdater < hdlbsp.util.SDUpdater.SDUpdater
    methods
        % Constructor, call the parent class
        function app = SDUpdater
            app@hdlbsp.util.SDUpdater.SDUpdater;
        end
    end
    
    methods (Access = protected)
        function configureApp(app)
            % Configure the SD Updater
            app.AppName ='Analog Devices SD Card Updater';
            app.FWMode = hdlbsp.util.SDUpdater.FWModes.FAT32_ZIP; % Firmware is stored in FAT32 zip files
            app.DeviceType = hdlbsp.util.SDUpdater.DeviceTypes.ZYNQ; % Zynq device
            %app.GUIEnabled = false;
        end
        
        function loadVariants(app)
            % Build the SD Card List
            vendorRootDir = fileparts(strtok(mfilename('fullpath'), '+'));
            PicoZedSDRDir = fullfile(vendorRootDir, '+AnalogDevices', '+PicoZedSDR');
			FMCOMMS2Dir = fullfile(vendorRootDir, '+AnalogDevices', '+FMCOMMS2');

            % Load the Variants
            SDZip = fullfile(PicoZedSDRDir, '+rfsom', 'rfsom_sdcard_2015_R1.zip');
            app.addVariant('AnalogDevices PicoZedSDR', 'Standard', SDZip);

			SDZip = fullfile(FMCOMMS2Dir, '+zc706', 'zc706_sdcard_2015_R1.zip');
            app.addVariant('AnalogDevices FMCOMMS2 + ZC706', 'Standard', SDZip);            
        end
        
    end
    
    methods
        function writeSDCard(app)
            % Pre-custom calls
            
            % call the parent function
            writeSDCard@hdlbsp.util.SDUpdater.SDUpdater(app);
            
            % Post-custom calls
            fprintf('Chosen Variant: %s\n', app.ActiveVariant);
        end
    end
end