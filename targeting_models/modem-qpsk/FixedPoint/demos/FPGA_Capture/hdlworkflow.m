%--------------------------------------------------------------------------
% HDL Workflow Script
% Generated with MATLAB 9.3 (R2017b) at 12:21:43 on 23/04/2018
% This script was generated using the following parameter values:
%     Filename  : 'C:\MathWorkSeminar\modem-phy\FixedPoint\demos\FPGA_Capture\hdlworkflow_rx_only.m'
%     Overwrite : true
%     Comments  : true
%     Headers   : true
%     DUT       : 'Receiver_FPGACapture/Receiver HDL'
% To view changes after modifying the workflow, run the following command:
% >> hWC.export('DUT','Receiver_FPGACapture/Receiver HDL');
%--------------------------------------------------------------------------

%% Load the Model
load_system('Receiver_FPGACapture');

%% Restore the Model to default HDL parameters
%hdlrestoreparams('Receiver_FPGACapture/Receiver HDL');

%% Model HDL Parameters
%% Set Model 'Receiver_FPGACapture' HDL parameters
hdlset_param('Receiver_FPGACapture', 'HDLSubsystem', 'Receiver_FPGACapture/Receiver HDL');
hdlset_param('Receiver_FPGACapture', 'ReferenceDesign', 'Receive path');
hdlset_param('Receiver_FPGACapture', 'ReferenceDesignParameter', {'boardName','ccfmc_lvds','project','adrv9361z7035','mw_hdl_dir','ipcore/mw','ad_hdl_dir','ipcore/adi','variant','rx','mw_board_name','adrv9361z7035','mw_adi_boardname','adrv9361z7035/ccfmc_lvds'});
hdlset_param('Receiver_FPGACapture', 'SynthesisTool', 'Xilinx Vivado');
hdlset_param('Receiver_FPGACapture', 'SynthesisToolChipFamily', 'Zynq');
hdlset_param('Receiver_FPGACapture', 'SynthesisToolDeviceName', 'xc7z035i');
hdlset_param('Receiver_FPGACapture', 'SynthesisToolPackageName', 'fbg676');
hdlset_param('Receiver_FPGACapture', 'SynthesisToolSpeedValue', '-2L');
hdlset_param('Receiver_FPGACapture', 'TargetDirectory', 'hdl_prj\hdlsrc');
hdlset_param('Receiver_FPGACapture', 'TargetFrequency', 20);
hdlset_param('Receiver_FPGACapture', 'TargetLanguage', 'Verilog');
hdlset_param('Receiver_FPGACapture', 'TargetPlatform', 'ADI RF SOM');
hdlset_param('Receiver_FPGACapture', 'Workflow', 'IP Core Generation');

% Set SubSystem HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL', 'ProcessorFPGASynchronization', 'Free running');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/FromRadioR', 'IOInterface', 'Baseband Rx I1 In [0:15]');
hdlset_param('Receiver_FPGACapture/Receiver HDL/FromRadioR', 'IOInterfaceMapping', '[0:15]');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/FromRadioI', 'IOInterface', 'Baseband Rx Q1 In [0:15]');
hdlset_param('Receiver_FPGACapture/Receiver HDL/FromRadioI', 'IOInterfaceMapping', '[0:15]');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/validIn', 'IOInterface', 'Baseband Rx Valid In');
hdlset_param('Receiver_FPGACapture/Receiver HDL/validIn', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/FRLoopBw', 'IOInterface', 'AXI4-Lite');
hdlset_param('Receiver_FPGACapture/Receiver HDL/FRLoopBw', 'IOInterfaceMapping', 'x"100"');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/EQmu', 'IOInterface', 'AXI4-Lite');
hdlset_param('Receiver_FPGACapture/Receiver HDL/EQmu', 'IOInterfaceMapping', 'x"104"');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Scope Select', 'IOInterface', 'AXI4-Lite');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Scope Select', 'IOInterfaceMapping', 'x"108"');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/DebugSelector', 'IOInterface', 'AXI4-Lite');
hdlset_param('Receiver_FPGACapture/Receiver HDL/DebugSelector', 'IOInterfaceMapping', 'x"10C"');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/BypassEQ', 'IOInterface', 'AXI4-Lite');
hdlset_param('Receiver_FPGACapture/Receiver HDL/BypassEQ', 'IOInterfaceMapping', 'x"114"');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/EnableDecode', 'IOInterface', 'AXI4-Lite');
hdlset_param('Receiver_FPGACapture/Receiver HDL/EnableDecode', 'IOInterfaceMapping', 'x"118"');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/PDThreshold', 'IOInterface', 'AXI4-Lite');
hdlset_param('Receiver_FPGACapture/Receiver HDL/PDThreshold', 'IOInterfaceMapping', 'x"11C"');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/TransmitToggle', 'IOInterface', 'AXI4-Lite');
hdlset_param('Receiver_FPGACapture/Receiver HDL/TransmitToggle', 'IOInterfaceMapping', 'x"120"');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/TransmitAlways', 'IOInterface', 'AXI4-Lite');
hdlset_param('Receiver_FPGACapture/Receiver HDL/TransmitAlways', 'IOInterfaceMapping', 'x"124"');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Loopback', 'IOInterface', 'AXI4-Lite');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Loopback', 'IOInterfaceMapping', 'x"12C"');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/BypassCoding', 'IOInterface', 'AXI4-Lite');
hdlset_param('Receiver_FPGACapture/Receiver HDL/BypassCoding', 'IOInterfaceMapping', 'x"130"');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/IQ Interface Mapper/real', 'IOInterface', 'No Interface Specified');
hdlset_param('Receiver_FPGACapture/Receiver HDL/IQ Interface Mapper/real', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/IQ Interface Mapper/imag', 'IOInterface', 'No Interface Specified');
hdlset_param('Receiver_FPGACapture/Receiver HDL/IQ Interface Mapper/imag', 'IOInterfaceMapping', '');

% Set SubSystem HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL', 'ProcessorFPGASynchronization', 'Free running');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/re', 'IOInterface', 'Rx data I1 In [0:15]');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/re', 'IOInterfaceMapping', '[0:15]');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/Im', 'IOInterface', 'Rx data Q1 In [0:15]');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/Im', 'IOInterfaceMapping', '[0:15]');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/Enable', 'IOInterface', 'Rx data Valid In');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/Enable', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/FRLoopBW', 'IOInterface', 'Rx data Valid In');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/FRLoopBW', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/EQmu', 'IOInterface', 'Rx data Valid In');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/EQmu', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/Scope Select', 'IOInterface', 'Rx data Valid In');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/Scope Select', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/DebugSelector', 'IOInterface', 'Rx data Valid In');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/DebugSelector', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/EQBypass', 'IOInterface', 'Rx data Valid In');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/EQBypass', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/EnableDecode', 'IOInterface', 'Rx data Valid In');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/EnableDecode', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/PDThreshold', 'IOInterface', 'Rx data Valid In');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/PDThreshold', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/BypassCoding', 'IOInterface', 'Rx data Valid In');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/BypassCoding', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/bytesOut', 'IOInterface', 'No Interface Specified');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/bytesOut', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/validOut', 'IOInterface', 'No Interface Specified');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/validOut', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/sync', 'IOInterface', 'No Interface Specified');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/sync', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/payloadLenOut', 'IOInterface', 'No Interface Specified');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/payloadLenOut', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/dataRe', 'IOInterface', 'Rx data I1 Out [0:15]');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/dataRe', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/dataIm', 'IOInterface', 'Rx data Q1 Out [0:15]');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/dataIm', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/validIQ', 'IOInterface', 'Rx data Valid Out');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/validIQ', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/DebugSelection', 'IOInterface', 'Rx data Valid Out');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/DebugSelection', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/RxTransferComplete', 'IOInterface', 'Rx data Valid Out');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Receiver HDL/RxTransferComplete', 'IOInterfaceMapping', '[0]');

% Set SubSystem HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Transmitter HDL', 'ProcessorFPGASynchronization', 'Free running');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Transmitter HDL/bytesIn', 'IOInterface', 'Tx data I1 In [0:15]');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Transmitter HDL/bytesIn', 'IOInterfaceMapping', '[0:15]');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Transmitter HDL/validIn', 'IOInterface', 'Tx data Valid In');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Transmitter HDL/validIn', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Transmitter HDL/BypassEncode', 'IOInterface', 'Tx data Valid In');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Transmitter HDL/BypassEncode', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Transmitter HDL/Packet Generation/trueData', 'IOInterface', 'Tx data Valid Out');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Transmitter HDL/Packet Generation/trueData', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Transmitter HDL/real', 'IOInterface', 'Tx data I1 Out [0:15]');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Transmitter HDL/real', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Transmitter HDL/imag', 'IOInterface', 'Tx data Q1 Out [0:15]');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Transmitter HDL/imag', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Transmitter HDL/validOut', 'IOInterface', 'Tx data Valid Out');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Transmitter HDL/validOut', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Transmitter HDL/Need Data', 'IOInterface', 'No Interface Specified');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Transmitter HDL/Need Data', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/Transmitter HDL/TxTransferComplete', 'IOInterface', 'Tx data Valid Out');
hdlset_param('Receiver_FPGACapture/Receiver HDL/Transmitter HDL/TxTransferComplete', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/reRx', 'IOInterface', 'DMA Rx I1 Out [0:15]');
hdlset_param('Receiver_FPGACapture/Receiver HDL/reRx', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/imRx', 'IOInterface', 'DMA Rx Q1 Out [0:15]');
hdlset_param('Receiver_FPGACapture/Receiver HDL/imRx', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/validRx', 'IOInterface', 'DMA Rx Valid Out');
hdlset_param('Receiver_FPGACapture/Receiver HDL/validRx', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/payloadLenOutRx', 'IOInterface', 'AXI4-Lite');
hdlset_param('Receiver_FPGACapture/Receiver HDL/payloadLenOutRx', 'IOInterfaceMapping', 'x"110"');

% Set Outport HDL parameters
hdlset_param('Receiver_FPGACapture/Receiver HDL/debugSelectionAXI', 'IOInterface', 'AXI4-Lite');
hdlset_param('Receiver_FPGACapture/Receiver HDL/debugSelectionAXI', 'IOInterfaceMapping', 'x"140"');


%% Workflow Configuration Settings
% Construct the Workflow Configuration Object with default settings
hWC = hdlcoder.WorkflowConfig('SynthesisTool','Xilinx Vivado','TargetWorkflow','IP Core Generation');

% Specify the top level project directory
hWC.ProjectFolder = 'hdl_prj';
hWC.ReferenceDesignToolVersion = '2017.4';
hWC.IgnoreToolVersionMismatch = false;

% Set Workflow tasks to run
hWC.RunTaskGenerateRTLCodeAndIPCore = true;
hWC.RunTaskCreateProject = true;
hWC.RunTaskGenerateSoftwareInterfaceModel = false;
hWC.RunTaskBuildFPGABitstream = true;
hWC.RunTaskProgramTargetDevice = false;

% Set properties related to 'RunTaskGenerateRTLCodeAndIPCore' Task
hWC.IPCoreRepository = '';
hWC.GenerateIPCoreReport = true;

% Set properties related to 'RunTaskCreateProject' Task
hWC.Objective = hdlcoder.Objective.None;
hWC.AdditionalProjectCreationTclFiles = '';
hWC.EnableIPCaching = false;

% Set properties related to 'RunTaskGenerateSoftwareInterfaceModel' Task
hWC.OperatingSystem = 'Linux';

% Set properties related to 'RunTaskBuildFPGABitstream' Task
hWC.RunExternalBuild = true;
hWC.TclFileForSynthesisBuild = hdlcoder.BuildOption.Default;
hWC.CustomBuildTclFile = '';

% Set properties related to 'RunTaskProgramTargetDevice' Task
hWC.ProgrammingMethod = hdlcoder.ProgrammingMethod.Download;

% Validate the Workflow Configuration Object
hWC.validate;

%% Run the workflow
hdlcoder.runWorkflow('Receiver_FPGACapture/Receiver HDL', hWC);
