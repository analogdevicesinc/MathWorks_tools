function install(mode)
% AnalogDevices.install adds/removes AnalogDevices HDL BSPs

% Copyright 2015 MathWorks, Inc. All Rights Reserved.

    if nargin == 0
        mode = 0;
    end

    %% Initialization   
    % Determine where we're operating out of
    vendorRootDir = fileparts(strtok(mfilename('fullpath'), '+'));    
    
    % Add/remove the common contents
    commonRootDir = fullfile(fileparts(fileparts(vendorRootDir)), 'common');
    olddir = cd(commonRootDir);
    cleanup = onCleanup(@()cd(olddir));
    hdlbsp.install(mode);
    
    
    % Add/remove the vendor contents
    paths = {...
        fullfile(vendorRootDir),...    
    };

    hdlbsp.util.vendorInstall(mode,paths);
	
	% Copy the Zynq SDR target definition file into the support package
	zynqRootDir   = codertarget.zynq.internal.getSpPkgRootDir;
	zynqTargetDir = fullfile(zynqRootDir,'registry/targethardware');
	source = fullfile(vendorRootDir, '/+AnalogDevices/+util/adizynqsdr.xml');
	destination = fullfile(zynqTargetDir, 'adizynqsdr.xml');
	copyfile(source, destination);
end