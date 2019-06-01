%--------------------------------------------------------------------------
% HDL Workflow Script
% Generated with MATLAB 9.5 (R2018b) at 16:05:58 on 14/05/2019
% This script was generated using the following parameter values:
%     Filename  : '/work/mwt-hopper/targeting_models/frequency-hopping/hdlworkflow2.m'
%     Overwrite : true
%     Comments  : true
%     Headers   : true
%     DUT       : 'frequency_hopping/HDL_DUT'
% To view changes after modifying the workflow, run the following command:
% >> hWC.export('DUT','frequency_hopping/HDL_DUT');
%--------------------------------------------------------------------------

%% Load the Model
load_system('frequency_hopping');

%% Restore the Model to default HDL parameters
%hdlrestoreparams('frequency_hopping/HDL_DUT');

%% Model HDL Parameters
%% Set Model 'frequency_hopping' HDL parameters
hdlset_param('frequency_hopping', 'HDLSubsystem', 'frequency_hopping/HDL_DUT');
hdlset_param('frequency_hopping', 'ReferenceDesign', 'ADRV9361 CCFMC_LVDS_HOP (Rx & Tx)');
hdlset_param('frequency_hopping', 'ReferenceDesignParameter', {'dma_config','Packetized'});
hdlset_param('frequency_hopping', 'SynthesisTool', 'Xilinx Vivado');
hdlset_param('frequency_hopping', 'SynthesisToolChipFamily', 'Zynq');
hdlset_param('frequency_hopping', 'SynthesisToolDeviceName', 'xc7z035i');
hdlset_param('frequency_hopping', 'SynthesisToolPackageName', 'fbg676');
hdlset_param('frequency_hopping', 'SynthesisToolSpeedValue', '-2L');
hdlset_param('frequency_hopping', 'TargetDirectory', 'hdl_prj/hdlsrc');
hdlset_param('frequency_hopping', 'TargetLanguage', 'Verilog');
hdlset_param('frequency_hopping', 'TargetPlatform', 'AnalogDevices ADRV9361-Z7035 Frequency Hopping');
hdlset_param('frequency_hopping', 'Workflow', 'IP Core Generation');

% Set SubSystem HDL parameters
hdlset_param('frequency_hopping/HDL_DUT', 'ProcessorFPGASynchronization', 'Free running');

% Set Inport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/inReal1', 'IOInterface', 'AD9361 ADC Data I0 [0:15]');
hdlset_param('frequency_hopping/HDL_DUT/inReal1', 'IOInterfaceMapping', '[0:15]');

% Set Inport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/inImag1', 'IOInterface', 'AD9361 ADC Data Q0 [0:15]');
hdlset_param('frequency_hopping/HDL_DUT/inImag1', 'IOInterfaceMapping', '[0:15]');

% Set Inport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/inReal', 'IOInterface', 'IP Data 0 IN [0:15]');
hdlset_param('frequency_hopping/HDL_DUT/inReal', 'IOInterfaceMapping', '[0:15]');

% Set Inport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/inImag', 'IOInterface', 'IP Data 1 IN [0:15]');
hdlset_param('frequency_hopping/HDL_DUT/inImag', 'IOInterfaceMapping', '[0:15]');

% Set Inport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/ctrl_out', 'IOInterface', 'CTRL_STATUS [0:7]');
hdlset_param('frequency_hopping/HDL_DUT/ctrl_out', 'IOInterfaceMapping', '[0:7]');

% Set Inport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/dwell_samples', 'IOInterface', 'AXI4-Lite');
hdlset_param('frequency_hopping/HDL_DUT/dwell_samples', 'IOInterfaceMapping', 'x"100"');

% Set Inport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/enableHopping', 'IOInterface', 'AXI4-Lite');
hdlset_param('frequency_hopping/HDL_DUT/enableHopping', 'IOInterfaceMapping', 'x"104"');

% Set Inport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/TxDMAEnable', 'IOInterface', 'DMA Ready');
hdlset_param('frequency_hopping/HDL_DUT/TxDMAEnable', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/manual_profile', 'IOInterface', 'AXI4-Lite');
hdlset_param('frequency_hopping/HDL_DUT/manual_profile', 'IOInterfaceMapping', 'x"120"');

% Set Inport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/use_manual', 'IOInterface', 'AXI4-Lite');
hdlset_param('frequency_hopping/HDL_DUT/use_manual', 'IOInterfaceMapping', 'x"124"');

% Set Inport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/force_enable', 'IOInterface', 'AXI4-Lite');
hdlset_param('frequency_hopping/HDL_DUT/force_enable', 'IOInterfaceMapping', 'x"108"');

% Set Outport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/outReal1', 'IOInterface', 'IP Data 0 OUT [0:15]');
hdlset_param('frequency_hopping/HDL_DUT/outReal1', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/outImag1', 'IOInterface', 'IP Data 1 OUT [0:15]');
hdlset_param('frequency_hopping/HDL_DUT/outImag1', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/outReal', 'IOInterface', 'AD9361 DAC Data I0 [0:15]');
hdlset_param('frequency_hopping/HDL_DUT/outReal', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/outImag', 'IOInterface', 'AD9361 DAC Data Q0 [0:15]');
hdlset_param('frequency_hopping/HDL_DUT/outImag', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/enable', 'IOInterface', 'IP Data Valid OUT');
hdlset_param('frequency_hopping/HDL_DUT/enable', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/ctrl_in', 'IOInterface', 'AD9361 CTRL IN [0:3]');
hdlset_param('frequency_hopping/HDL_DUT/ctrl_in', 'IOInterfaceMapping', '[0:3]');

% Set Outport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/profile', 'IOInterface', 'AXI4-Lite');
hdlset_param('frequency_hopping/HDL_DUT/profile', 'IOInterfaceMapping', 'x"10C"');

% Set Outport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/hop_delay', 'IOInterface', 'AXI4-Lite');
hdlset_param('frequency_hopping/HDL_DUT/hop_delay', 'IOInterfaceMapping', 'x"110"');

% Set Outport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/pll_status', 'IOInterface', 'AXI4-Lite');
hdlset_param('frequency_hopping/HDL_DUT/pll_status', 'IOInterfaceMapping', 'x"114"');

% Set Outport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/hop_count', 'IOInterface', 'AXI4-Lite');
hdlset_param('frequency_hopping/HDL_DUT/hop_count', 'IOInterfaceMapping', 'x"118"');

% Set Outport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/state', 'IOInterface', 'AXI4-Lite');
hdlset_param('frequency_hopping/HDL_DUT/state', 'IOInterfaceMapping', 'x"11C"');

% Set Outport HDL parameters
hdlset_param('frequency_hopping/HDL_DUT/pll_unlocks', 'IOInterface', 'AXI4-Lite');
hdlset_param('frequency_hopping/HDL_DUT/pll_unlocks', 'IOInterfaceMapping', 'x"128"');


%% Workflow Configuration Settings
% Construct the Workflow Configuration Object with default settings
hWC = hdlcoder.WorkflowConfig('SynthesisTool','Xilinx Vivado','TargetWorkflow','IP Core Generation');

% Specify the top level project directory
hWC.ProjectFolder = 'hdl_prj';
hWC.ReferenceDesignToolVersion = '2018.2';
hWC.IgnoreToolVersionMismatch = false;

% Set Workflow tasks to run
hWC.RunTaskGenerateRTLCodeAndIPCore = true;
hWC.RunTaskCreateProject = true;
hWC.RunTaskGenerateSoftwareInterfaceModel = false;
hWC.RunTaskBuildFPGABitstream = true;
hWC.RunTaskProgramTargetDevice = false;

% Set properties related to 'RunTaskGenerateRTLCodeAndIPCore' Task
hWC.IPCoreRepository = '';
hWC.GenerateIPCoreReport = false;

% Set properties related to 'RunTaskCreateProject' Task
hWC.Objective = hdlcoder.Objective.None;
hWC.AdditionalProjectCreationTclFiles = '';
hWC.EnableIPCaching = false;

% Set properties related to 'RunTaskGenerateSoftwareInterfaceModel' Task
hWC.OperatingSystem = '';

% Set properties related to 'RunTaskBuildFPGABitstream' Task
hWC.RunExternalBuild = false;
hWC.TclFileForSynthesisBuild = hdlcoder.BuildOption.Custom;
hWC.CustomBuildTclFile = 'adi_build.tcl';

% Set properties related to 'RunTaskProgramTargetDevice' Task
hWC.ProgrammingMethod = hdlcoder.ProgrammingMethod.Download;

% Validate the Workflow Configuration Object
hWC.validate;

%% Run the workflow
try
    hdlcoder.runWorkflow('frequency_hopping/HDL_DUT', hWC);
    bdclose('all');
    out = [];
catch ME
    if exist('hdl_prj/vivado_ip_prj/boot/BOOT.BIN','file')
       ME = []; 
    end
    out = ME;%.identifier
end
