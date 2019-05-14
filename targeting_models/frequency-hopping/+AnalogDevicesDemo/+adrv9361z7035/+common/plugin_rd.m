function hRD = plugin_rd(board, design)
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Construct reference design object
hRD = hdlcoder.ReferenceDesign('SynthesisTool', 'Xilinx Vivado');

% Create the reference design for the SOM-only
% This is the base reference design that other RDs can build upon
hRD.ReferenceDesignName = sprintf('ADRV9361 %s (%s)', upper(board), design);

% Determine the board name based on the design
hRD.BoardName = sprintf('AnalogDevices ADRV9361-Z7035 Frequency Hopping');

% Tool information
hRD.SupportedToolVersion = {'2017.4'};

% DMA Configuration
hRD.addParameter( ...
    'ParameterID',   'dma_config', ...
    'DisplayName',   'DMA Config', ...
    'DefaultValue',  'Stream', ...
    'ParameterType',  hdlcoder.ParameterType.Dropdown, ...
    'Choice',       {'Stream', 'Packetized'});

% Get the root directories
rootDirExample = fileparts(strtok(mfilename('fullpath'), '+'));
tmp = strsplit(rootDirExample,'/');

rootDir = fullfile('/',tmp{1:end-2});
rootDirBSP = fullfile('hdl_wa_bsp','vendor','AnalogDevices','vivado');

% Design files are shared
hRD.SharedRD = true;
hRD.SharedRDFolder = rootDir;

%% Add custom design files
% add custom Vivado design
hRD.addCustomVivadoDesign( ...
    'CustomBlockDesignTcl', fullfile('targeting_models', 'frequency-hopping', 'ccfmc_lvds_hop', 'system_project_rx_tx.tcl'), ...
    'CustomTopLevelHDL',    fullfile('targeting_models', 'frequency-hopping', 'ccfmc_lvds_hop', 'system_top.v'));		


%% Standard reference design pieces
hRD.BlockDesignName = 'system';	
	
% custom constraint files
board_type = strsplit(board,'_');
hRD.CustomConstraints = {...
    fullfile(rootDirBSP, 'projects', 'adrv9361z7035', 'common', strcat(board_type{1}, '_constr.xdc')), ...
	fullfile(rootDirBSP, 'projects', 'adrv9361z7035', 'common', 'adrv9361z7035_constr.xdc'), ...
	fullfile(rootDirBSP, 'projects', 'adrv9361z7035', 'common', strcat('adrv9361z7035_constr_', board_type{2}, '.xdc')), ...
    };

% custom source files
hRD.CustomFiles = {...
	fullfile(rootDirBSP, 'library')...,
	fullfile(rootDirBSP, 'library','xilinx')...,
	fullfile(rootDirBSP, 'projects','common')...,
	fullfile(rootDirBSP, 'projects','scripts')...,
	fullfile(rootDirBSP, 'projects','fmcomms2')...,
	fullfile(rootDirBSP, 'projects','adrv9361z7035', 'common')...,
    fullfile('targeting_models', 'frequency-hopping', 'ccfmc_lvds_hop')...,
    };	
	
%% Add interfaces
% add clock interface
hRD.addClockInterface( ...
    'ClockConnection',   'util_ad9361_divclk/clk_out', ...
    'ResetConnection',   'util_ad9361_divclk_reset/peripheral_aresetn');
	
