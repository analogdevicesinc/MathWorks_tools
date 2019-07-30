%--------------------------------------------------------------------------
% HDL Workflow Script
% Generated with MATLAB 9.6 (R2019a) at 12:36:48 on 24/07/2019
% This script was generated using the following parameter values:
%     Filename  : 'C:\git\MathWorks_tools\targeting_models\tuneAGC-ad9361\hdlworkflow.m'
%     Overwrite : true
%     Comments  : true
%     Headers   : true
%     DUT       : 'ad9361_rx_wlan_testbench_targeting/HDL_DUT'
% To view changes after modifying the workflow, run the following command:
% >> hWC.export('DUT','ad9361_rx_wlan_testbench_targeting/HDL_DUT');
%--------------------------------------------------------------------------

%% Load the Model
load_system('ad9361_rx_wlan_testbench_targeting');

%% Restore the Model to default HDL parameters
%hdlrestoreparams('ad9361_rx_wlan_testbench_targeting/HDL_DUT');

%% Model HDL Parameters
%% Set Model 'ad9361_rx_wlan_testbench_targeting' HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting', 'HDLSubsystem', 'ad9361_rx_wlan_testbench_targeting/HDL_DUT');
hdlset_param('ad9361_rx_wlan_testbench_targeting', 'ReferenceDesign', 'FMC LVDS AGC (Rx)');
hdlset_param('ad9361_rx_wlan_testbench_targeting', 'SynthesisTool', 'Xilinx Vivado');
hdlset_param('ad9361_rx_wlan_testbench_targeting', 'SynthesisToolChipFamily', 'Zynq');
hdlset_param('ad9361_rx_wlan_testbench_targeting', 'SynthesisToolDeviceName', 'xc7z035i');
hdlset_param('ad9361_rx_wlan_testbench_targeting', 'SynthesisToolPackageName', 'fbg676');
hdlset_param('ad9361_rx_wlan_testbench_targeting', 'SynthesisToolSpeedValue', '-2L');
hdlset_param('ad9361_rx_wlan_testbench_targeting', 'TargetDirectory', 'hdl_prj\hdlsrc');
hdlset_param('ad9361_rx_wlan_testbench_targeting', 'TargetLanguage', 'Verilog');
hdlset_param('ad9361_rx_wlan_testbench_targeting', 'TargetPlatform', 'AnalogDevices ADRV9361-Z7035 AGC');
hdlset_param('ad9361_rx_wlan_testbench_targeting', 'Workflow', 'IP Core Generation');

% Set SubSystem HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT', 'IPDataCaptureBufferSize', '16384');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT', 'ProcessorFPGASynchronization', 'Free running');

% Set Inport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/in1', 'IOInterface', 'AD9361 ADC Data I0 [0:15]');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/in1', 'IOInterfaceMapping', '[0:15]');

% Set Inport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/in2', 'IOInterface', 'AD9361 ADC Data Q0 [0:15]');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/in2', 'IOInterfaceMapping', '[0:15]');

% Set Inport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/enable', 'IOInterface', 'No Interface Specified');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/enable', 'IOInterfaceMapping', '');

% Set Inport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/threshold', 'IOInterface', 'AXI4-Lite');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/threshold', 'IOInterfaceMapping', 'x"100"');

% Set Inport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/enablePD', 'IOInterface', 'AXI4-Lite');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/enablePD', 'IOInterfaceMapping', 'x"104"');

% Set Inport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/enableNCO', 'IOInterface', 'AXI4-Lite');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/enableNCO', 'IOInterfaceMapping', 'x"11C"');

% Set Inport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/enableLatch', 'IOInterface', 'AXI4-Lite');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/enableLatch', 'IOInterfaceMapping', 'x"10C"');

% Set Inport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/dmaReady', 'IOInterface', 'DMA Ready');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/dmaReady', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/EN_AGC_CTRL', 'IOInterface', 'AXI4-Lite');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/EN_AGC_CTRL', 'IOInterfaceMapping', 'x"124"');

% Set Inport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/packetLength', 'IOInterface', 'AXI4-Lite');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/packetLength', 'IOInterfaceMapping', 'x"108"');

% Set Inport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/ctrlstatus', 'IOInterface', 'AD9361 CTRL OUT [0:7]');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/ctrlstatus', 'IOInterfaceMapping', '[0:7]');

% Set Outport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/Output Interface/enable', 'IOInterface', 'AXI4-Lite');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/Output Interface/enable', 'IOInterfaceMapping', 'x"104"');

% Set Outport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/Output Interface/syncReal', 'IOInterface', 'DMA Rx I1 Out [0:15]');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/Output Interface/syncReal', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/Output Interface/syncImag', 'IOInterface', 'DMA Rx Q1 Out [0:15]');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/Output Interface/syncImag', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/Output Interface/syncReal1', 'IOInterface', 'DMA Rx I1 Out [0:15]');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/Output Interface/syncReal1', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/Output Interface/syncImag1', 'IOInterface', 'DMA Rx Q1 Out [0:15]');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/Output Interface/syncImag1', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/enableOut', 'IOInterface', 'IP Data Valid OUT');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/enableOut', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/syncReal', 'IOInterface', 'IP Data 0 OUT [0:15]');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/syncReal', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/syncImag', 'IOInterface', 'IP Data 1 OUT [0:15]');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/syncImag', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/DebugStart', 'IOInterface', 'AXI4-Lite');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/DebugStart', 'IOInterfaceMapping', 'x"110"');

% Set Outport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/DebugPacketsFound', 'IOInterface', 'AXI4-Lite');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/DebugPacketsFound', 'IOInterfaceMapping', 'x"114"');

% Set Outport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/DebugLastFreqEst', 'IOInterface', 'AXI4-Lite');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/DebugLastFreqEst', 'IOInterfaceMapping', 'x"118"');

% Set Outport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/DebugPDsTriggered', 'IOInterface', 'AXI4-Lite');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/DebugPDsTriggered', 'IOInterfaceMapping', 'x"120"');

% Set Outport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/DebugEnablesHigh', 'IOInterface', 'AXI4-Lite');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/DebugEnablesHigh', 'IOInterfaceMapping', 'x"128"');

% Set Outport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/syncReal1', 'IOInterface', 'IP Data 2 OUT [0:15]');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/syncReal1', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/syncImag1', 'IOInterface', 'IP Data 3 OUT [0:15]');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/syncImag1', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/EN_AGC', 'IOInterface', 'Enable AGC');
hdlset_param('ad9361_rx_wlan_testbench_targeting/HDL_DUT/EN_AGC', 'IOInterfaceMapping', '[0]');


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
    hdlcoder.runWorkflow('ad9361_rx_wlan_testbench_targeting/HDL_DUT', hWC);
    bdclose('all');
    out = [];
catch ME
    if exist('hdl_prj/vivado_ip_prj/boot/BOOT.BIN','file')
       ME = []; 
    end
    out = ME;%.identifier
end

