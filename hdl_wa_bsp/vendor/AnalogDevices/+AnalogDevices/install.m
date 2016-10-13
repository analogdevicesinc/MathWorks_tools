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
	source  = [];
	destination = [];
	zynqRootDir = codertarget.zynq.internal.getSpPkgRootDir;
    armRootDir  = codertarget.arm_cortex_a.internal.getSpPkgRootDir;
	
	zynqTargetDir = fullfile(zynqRootDir,'registry/targethardware');
	source = [source {fullfile(vendorRootDir, '/+AnalogDevices/+util/adizynqsdr.xml')}];
	destination = [destination {fullfile(zynqTargetDir, 'adizynqsdr.xml')}];
	
	zynqTargetDir = fullfile(zynqRootDir,'registry/attributes');
	source = [source {fullfile(vendorRootDir, '/+AnalogDevices/+util/ADIZynqSDRAttributeInfo.xml')}];
	destination = [destination {fullfile(zynqTargetDir, 'ADIZynqSDRAttributeInfo.xml')}];
	
	zynqTargetDir = fullfile(zynqRootDir,'registry/parameters');
	source = [source {fullfile(vendorRootDir, '/+AnalogDevices/+util/ADIZynqSDRParameterInfo.xml')}];
	destination = [destination {fullfile(zynqTargetDir, 'ADIZynqSDRParameterInfo.xml')}];
	
	source = [source {fullfile(vendorRootDir, '/+AnalogDevices/+util/extmodeHooksADI.m')}];
	destination = [destination {fullfile(zynqRootDir, '/+codertarget/+zynq/+internal/extmodeHooksADI.m')}];
	
    source = [source {fullfile(armRootDir,'ssh_download.bat')}];
    destination = [destination {fullfile(zynqRootDir, 'ssh_download.bat')}];
    
	if(mode == 0)
        for i = 1:length(source)
            copyfile(char(source(:,i)), char(destination(:,i)), 'f');
        end
    else
        for i = 1:length(destination)
            delete(char(destination(:,i)));
        end
	end	
end