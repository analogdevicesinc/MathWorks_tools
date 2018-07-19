
function out = build_design(config,ReferenceDesignName,vivado_version,mode,device)
%% Load the Model
mdl = 'testModel';
load_system(mdl);
numChannels = 4;

%% Restore the Model to default HDL parameters
%hdlrestoreparams('testModel/HDL_DUT');

%% Model HDL Parameters

%% Set Model mdl HDL parameters
hdlset_param(mdl, 'HDLSubsystem', [mdl,'/HDL_DUT']);
hdlset_param(mdl, 'ReferenceDesign', ReferenceDesignName);
hdlset_param(mdl, 'SynthesisTool', config.SupportedTool{:});
hdlset_param(mdl, 'SynthesisToolChipFamily', config.FPGAFamily);
hdlset_param(mdl, 'SynthesisToolDeviceName', config.FPGADevice);
hdlset_param(mdl, 'SynthesisToolPackageName', config.FPGAPackage);
hdlset_param(mdl, 'SynthesisToolSpeedValue', config.FPGASpeed);
hdlset_param(mdl, 'TargetPlatform', config.BoardName);
hdlset_param(mdl, 'TargetLanguage', 'Verilog');
hdlset_param(mdl, 'TargetDirectory', 'hdl_prj\hdlsrc');
hdlset_param(mdl, 'Workflow', 'IP Core Generation');
hdlset_param([mdl,'/HDL_DUT'], 'ProcessorFPGASynchronization', 'Free running');

%% Set port mapping based on design configuration
setportmapping(mdl,mode,numChannels,device);

%% Workflow Configuration Settings
% Construct the Workflow Configuration Object with default settings
hWC = hdlcoder.WorkflowConfig('SynthesisTool','Xilinx Vivado','TargetWorkflow','IP Core Generation');

% Specify the top level project directory
hWC.ProjectFolder = 'hdl_prj';
hWC.ReferenceDesignToolVersion = vivado_version;
hWC.IgnoreToolVersionMismatch = true;

% Set Workflow tasks to run
hWC.RunTaskGenerateRTLCodeAndIPCore = true;
hWC.RunTaskCreateProject = true;
hWC.RunTaskGenerateSoftwareInterfaceModel = false;
hWC.RunTaskBuildFPGABitstream = false; % CHANGED
hWC.RunTaskProgramTargetDevice = false;

% Set properties related to 'RunTaskGenerateRTLCodeAndIPCore' Task
hWC.IPCoreRepository = '';
hWC.GenerateIPCoreReport = false;

% Set properties related to 'RunTaskCreateProject' Task
hWC.Objective = hdlcoder.Objective.None;
hWC.AdditionalProjectCreationTclFiles = '';
hWC.EnableIPCaching = false;

% Set properties related to 'RunTaskGenerateSoftwareInterfaceModel' Task
hWC.OperatingSystem = 'Linux';

% Set properties related to 'RunTaskBuildFPGABitstream' Task
hWC.RunExternalBuild = false;
%hWC.TclFileForSynthesisBuild = hdlcoder.BuildOption.Default;
%hWC.CustomBuildTclFile = '';
hWC.TclFileForSynthesisBuild = hdlcoder.BuildOption.Custom;
hWC.CustomBuildTclFile = '../hdl_wa_bsp/vendor/AnalogDevices/vivado/projects/scripts/adi_build.tcl';

% Set properties related to 'RunTaskProgramTargetDevice' Task
%hWC.ProgrammingMethod = hdlcoder.ProgrammingMethod.Download;
%hWC.ProgrammingMethod = hdlcoder.ProgrammingMethod.Custom;

% Validate the Workflow Configuration Object
hWC.validate;

%% Run the workflow
try
    hdlcoder.runWorkflow([mdl,'/HDL_DUT'], hWC);
    close_system(mdl, false);
    bdclose('all');
    out = [];
catch ME
    out = ME;%.identifier
end

