%--------------------------------------------------------------------------
% HDL Workflow Script
% Generated with MATLAB 9.3 (R2017b) at 14:05:38 on 07/05/2018
% This script was generated using the following parameter values:
%     Filename  : '/tmp/MathWorks_tools/targeting_models/modem-qpsk/FixedPoint/demos/ADI_DMA_TT/hdlworkflow.m'
%     Overwrite : true
%     Comments  : true
%     Headers   : true
%     DUT       : 'combinedTxRx_ADIDMA/Combined TX and RX'
% To view changes after modifying the workflow, run the following command:
% >> hWC.export('DUT','combinedTxRx_ADIDMA/Combined TX and RX');
%--------------------------------------------------------------------------

%% Load the Model
load_system('combinedTxRx_ADIDMA');

%% Restore the Model to default HDL parameters
%hdlrestoreparams('combinedTxRx_ADIDMA/Combined TX and RX');

%% Model HDL Parameters
%% Set Model 'combinedTxRx_ADIDMA' HDL parameters
hdlset_param('combinedTxRx_ADIDMA', 'HDLSubsystem', 'combinedTxRx_ADIDMA/Combined TX and RX');
hdlset_param('combinedTxRx_ADIDMA', 'ReferenceDesign', 'adrv9361z7035 box lvds Base System (Vivado 2017.4)');
hdlset_param('combinedTxRx_ADIDMA', 'SynthesisTool', 'Xilinx Vivado');
hdlset_param('combinedTxRx_ADIDMA', 'SynthesisToolChipFamily', 'Zynq');
hdlset_param('combinedTxRx_ADIDMA', 'SynthesisToolDeviceName', 'xc7z035i');
hdlset_param('combinedTxRx_ADIDMA', 'SynthesisToolPackageName', 'fbg676');
hdlset_param('combinedTxRx_ADIDMA', 'SynthesisToolSpeedValue', '-2L');
hdlset_param('combinedTxRx_ADIDMA', 'TargetDirectory', 'hdl_prj/hdlsrc');
hdlset_param('combinedTxRx_ADIDMA', 'TargetLanguage', 'Verilog');
hdlset_param('combinedTxRx_ADIDMA', 'TargetPlatform', 'AnalogDevices adrv9361z7035 box lvds (modem)');
hdlset_param('combinedTxRx_ADIDMA', 'Workflow', 'IP Core Generation');

% Set SubSystem HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX', 'ProcessorFPGASynchronization', 'Free running');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/bytesIn', 'IOInterface', 'IP Data IN [0:63]');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/bytesIn', 'IOInterfaceMapping', '[0:63]');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/validIn', 'IOInterface', 'IP Valid Tx Data IN');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/validIn', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/FromRadioR', 'IOInterface', 'AD9361 ADC Data I0 [0:15]');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/FromRadioR', 'IOInterfaceMapping', '[0:15]');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/FromRadioI', 'IOInterface', 'AD9361 ADC Data Q0 [0:15]');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/FromRadioI', 'IOInterfaceMapping', '[0:15]');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/FRLoopBw', 'IOInterface', 'AXI4-Lite');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/FRLoopBw', 'IOInterfaceMapping', 'x"100"');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/EQmu', 'IOInterface', 'AXI4-Lite');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/EQmu', 'IOInterfaceMapping', 'x"104"');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Scope Select', 'IOInterface', 'AXI4-Lite');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Scope Select', 'IOInterfaceMapping', 'x"108"');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/DebugSelector', 'IOInterface', 'AXI4-Lite');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/DebugSelector', 'IOInterfaceMapping', 'x"10C"');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/TxDMASelectIn', 'IOInterface', 'AXI4-Lite');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/TxDMASelectIn', 'IOInterfaceMapping', 'x"110"');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/BypassEQ', 'IOInterface', 'AXI4-Lite');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/BypassEQ', 'IOInterfaceMapping', 'x"114"');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/EnableDecode', 'IOInterface', 'AXI4-Lite');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/EnableDecode', 'IOInterfaceMapping', 'x"118"');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/PDThreshold', 'IOInterface', 'AXI4-Lite');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/PDThreshold', 'IOInterfaceMapping', 'x"11C"');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/TransmitToggle', 'IOInterface', 'AXI4-Lite');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/TransmitToggle', 'IOInterfaceMapping', 'x"120"');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/TransmitAlways', 'IOInterface', 'AXI4-Lite');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/TransmitAlways', 'IOInterfaceMapping', 'x"124"');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/PacketSource', 'IOInterface', 'AXI4-Lite');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/PacketSource', 'IOInterfaceMapping', 'x"128"');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Loopback', 'IOInterface', 'AXI4-Lite');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Loopback', 'IOInterfaceMapping', 'x"12C"');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/BypassCoding', 'IOInterface', 'AXI4-Lite');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/BypassCoding', 'IOInterfaceMapping', 'x"130"');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/IQ Interface Mapper/bytesOut', 'IOInterface', 'No Interface Specified');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/IQ Interface Mapper/bytesOut', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/IQ Interface Mapper/validBytesOut', 'IOInterface', 'No Interface Specified');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/IQ Interface Mapper/validBytesOut', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/IQ Interface Mapper/startPacketOut', 'IOInterface', 'No Interface Specified');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/IQ Interface Mapper/startPacketOut', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/IQ Interface Mapper/real', 'IOInterface', 'No Interface Specified');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/IQ Interface Mapper/real', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/IQ Interface Mapper/imag', 'IOInterface', 'No Interface Specified');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/IQ Interface Mapper/imag', 'IOInterfaceMapping', '');

% Set SubSystem HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL', 'ProcessorFPGASynchronization', 'Free running');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/re', 'IOInterface', 'Rx data I1 In [0:15]');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/re', 'IOInterfaceMapping', '[0:15]');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/Im', 'IOInterface', 'Rx data Q1 In [0:15]');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/Im', 'IOInterfaceMapping', '[0:15]');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/Enable', 'IOInterface', 'Rx data Valid In');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/Enable', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/FRLoopBW', 'IOInterface', 'Rx data Valid In');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/FRLoopBW', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/EQmu', 'IOInterface', 'Rx data Valid In');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/EQmu', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/Scope Select', 'IOInterface', 'Rx data Valid In');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/Scope Select', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/DebugSelector', 'IOInterface', 'Rx data Valid In');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/DebugSelector', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/EQBypass', 'IOInterface', 'Rx data Valid In');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/EQBypass', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/EnableDecode', 'IOInterface', 'Rx data Valid In');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/EnableDecode', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/PDThreshold', 'IOInterface', 'Rx data Valid In');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/PDThreshold', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/BypassCoding', 'IOInterface', 'Rx data Valid In');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/BypassCoding', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/bytesOut', 'IOInterface', 'No Interface Specified');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/bytesOut', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/validOut', 'IOInterface', 'No Interface Specified');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/validOut', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/sync', 'IOInterface', 'No Interface Specified');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/sync', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/payloadLenOut', 'IOInterface', 'No Interface Specified');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/payloadLenOut', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/dataRe', 'IOInterface', 'Rx data I1 Out [0:15]');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/dataRe', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/dataIm', 'IOInterface', 'Rx data Q1 Out [0:15]');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/dataIm', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/validIQ', 'IOInterface', 'Rx data Valid Out');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/validIQ', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/DebugSelection', 'IOInterface', 'Rx data Valid Out');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/DebugSelection', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/RxTransferComplete', 'IOInterface', 'Rx data Valid Out');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Receiver HDL/RxTransferComplete', 'IOInterfaceMapping', '[0]');

% Set SubSystem HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Transmitter HDL', 'ProcessorFPGASynchronization', 'Free running');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Transmitter HDL/bytesIn', 'IOInterface', 'Tx data I1 In [0:15]');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Transmitter HDL/bytesIn', 'IOInterfaceMapping', '[0:15]');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Transmitter HDL/validIn', 'IOInterface', 'Tx data Valid In');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Transmitter HDL/validIn', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Transmitter HDL/BypassEncode', 'IOInterface', 'Tx data Valid In');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Transmitter HDL/BypassEncode', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Transmitter HDL/Packet Generation/trueData', 'IOInterface', 'Tx data Valid Out');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Transmitter HDL/Packet Generation/trueData', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Transmitter HDL/real', 'IOInterface', 'Tx data I1 Out [0:15]');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Transmitter HDL/real', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Transmitter HDL/imag', 'IOInterface', 'Tx data Q1 Out [0:15]');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Transmitter HDL/imag', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Transmitter HDL/validOut', 'IOInterface', 'Tx data Valid Out');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Transmitter HDL/validOut', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Transmitter HDL/Need Data', 'IOInterface', 'No Interface Specified');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Transmitter HDL/Need Data', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Transmitter HDL/TxTransferComplete', 'IOInterface', 'Tx data Valid Out');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/Transmitter HDL/TxTransferComplete', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/ToRadioR', 'IOInterface', 'AD9361 DAC Data I0 [0:15]');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/ToRadioR', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/ToRadioI', 'IOInterface', 'AD9361 DAC Data Q0 [0:15]');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/ToRadioI', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/ToRadioValid', 'IOInterface', 'IP Valid Tx Data OUT');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/ToRadioValid', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/NeedData', 'IOInterface', 'IP Load Tx Data OUT');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/NeedData', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/BytesOutRx', 'IOInterface', 'IP Data OUT [0:63]');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/BytesOutRx', 'IOInterfaceMapping', '[0:63]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/payloadLenOutRx', 'IOInterface', 'No Interface Specified');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/payloadLenOutRx', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/ValidOutRx', 'IOInterface', 'IP Data Valid OUT');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/ValidOutRx', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/syncRx', 'IOInterface', 'ADC DMA sync');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/syncRx', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/reRx', 'IOInterface', 'IP Debug 1 OUT [0:15]');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/reRx', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/imRx', 'IOInterface', 'IP Debug 2 OUT [0:15]');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/imRx', 'IOInterfaceMapping', '[0:15]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/validRx', 'IOInterface', 'No Interface Specified');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/validRx', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/TxDMASelectOut', 'IOInterface', 'Tx Mux Sel');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/TxDMASelectOut', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/debugSelectionAXI', 'IOInterface', 'AXI4-Lite');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/debugSelectionAXI', 'IOInterfaceMapping', 'x"140"');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/TxTransferComplete', 'IOInterface', 'No Interface Specified');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/TxTransferComplete', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/RxTransferComplete', 'IOInterface', 'No Interface Specified');
hdlset_param('combinedTxRx_ADIDMA/Combined TX and RX/RxTransferComplete', 'IOInterfaceMapping', '');


%% Workflow Configuration Settings
% Construct the Workflow Configuration Object with default settings
hWC = hdlcoder.WorkflowConfig('SynthesisTool','Xilinx Vivado','TargetWorkflow','IP Core Generation');

% Specify the top level project directory
hWC.ProjectFolder = 'hdl_prj';
hWC.ReferenceDesignToolVersion = '2016.4';
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
hWC.OperatingSystem = '';

% Set properties related to 'RunTaskBuildFPGABitstream' Task
hWC.RunExternalBuild = true;
hWC.TclFileForSynthesisBuild = hdlcoder.BuildOption.Custom;
hWC.CustomBuildTclFile = 'adi_build.tcl';

% Set properties related to 'RunTaskProgramTargetDevice' Task
hWC.ProgrammingMethod = hdlcoder.ProgrammingMethod.Download;

% Validate the Workflow Configuration Object
hWC.validate;

%% Run the workflow
hdlcoder.runWorkflow('combinedTxRx_ADIDMA/Combined TX and RX', hWC);
