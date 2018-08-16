cd(fileparts((mfilename('fullpath'))));
cd ../..
projectFile = 'CI/scripts/bsp.prj';
currentVersion = matlab.addons.toolbox.toolboxVersion(projectFile);
outputFile = ['AnalogDevicesBSP_v',currentVersion];
matlab.addons.toolbox.packageToolbox(projectFile,outputFile)
