function hRD = plugin_rd(board, design)
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Construct reference design object
hRD = hdlcoder.ReferenceDesign('SynthesisTool', 'Xilinx Vivado');

% Create the reference design for the SOM-only
% This is the base reference design that other RDs can build upon
hRD.ReferenceDesignName = sprintf('adrv9361z7035 %s Base System',board);

% Determine the board name based on the design
hRD.BoardName = sprintf('AnalogDevices adrv9361z7035 %s (%s)', board, design);

% Tool information
if contains(upper(design),'MODEM')
	hRD.SupportedToolVersion = {'2016.4'};%MODEM
else
	v = adi.Version;
	hRD.SupportedToolVersion = {v.VivadoShort};
end

% Get the root directory
rootDir = fileparts(strtok(mfilename('fullpath'), '+'));

% Design files are shared
hRD.SharedRD = true;
hRD.SharedRDFolder = fullfile(rootDir, 'vivado');

switch(upper(board))
	case 'BOX LVDS'
		board = 'ccbox_lvds';
	case 'BOB LVDS'
		board = 'ccbob_lvds';
	case 'BOB CMOS'
		board = 'ccbob_cmos';
	case 'FMC LVDS'
		board = 'ccfmc_lvds';
	case 'FMC CMOS'
		board = 'ccfmc_cmos';
	case 'PCI LVDS'
		board = 'ccpci_lvds';
	case 'USB LVDS'
		board = 'ccusb_lvds';
	otherwise
		board = 'ccbrk_lvds';
end

%% Add custom design files
% add custom Vivado design
switch(upper(design))
	case 'RX'
		hRD.addCustomVivadoDesign( ...
			'CustomBlockDesignTcl', fullfile('projects', 'adrv9361z7035', lower(board), 'system_project_rx.tcl'), ...
			'CustomTopLevelHDL',    fullfile('projects', 'adrv9361z7035', lower(board), 'system_top.v'));
	case 'TX'
		hRD.addCustomVivadoDesign( ...
			'CustomBlockDesignTcl', fullfile('projects', 'adrv9361z7035', lower(board), 'system_project_tx.tcl'), ...
			'CustomTopLevelHDL',    fullfile('projects', 'adrv9361z7035', lower(board), 'system_top.v'));
	case 'RX & TX'
		hRD.addCustomVivadoDesign( ...
			'CustomBlockDesignTcl', fullfile('projects', 'adrv9361z7035', lower(board), 'system_project_rx_tx.tcl'), ...
			'CustomTopLevelHDL',    fullfile('projects', 'adrv9361z7035', lower(board), 'system_top.v'));
	case 'MODEM'
		board = 'ccbox_lvds_modem';
		hRD.addCustomVivadoDesign( ...
			'CustomBlockDesignTcl', fullfile('projects', 'adrv9361z7035', lower(board), 'system_project_rx_tx.tcl'), ...
			'CustomTopLevelHDL',    fullfile('projects', 'adrv9361z7035', lower(board), 'system_top.v'));
	otherwise
		hRD.addCustomVivadoDesign( ...
			'CustomBlockDesignTcl', fullfile('projects', 'adrv9361z7035', lower(board), 'system_project.tcl'), ...
			'CustomTopLevelHDL',    fullfile('projects', 'adrv9361z7035', lower(board), 'system_top.v'));
end

hRD.BlockDesignName = 'system';

% custom constraint files
board_type = strsplit(board,'_');
hRD.CustomConstraints = {...
    fullfile('projects', 'adrv9361z7035', 'common', strcat(board_type{1}, '_constr.xdc')), ...
	fullfile('projects', 'adrv9361z7035', 'common', 'adrv9361z7035_constr.xdc'), ...
	fullfile('projects', 'adrv9361z7035', 'common', strcat('adrv9361z7035_constr_', board_type{2}, '.xdc')), ...
    };

% custom source files
hRD.CustomFiles = {...
	fullfile('library')...,
	fullfile('library','xilinx')...,
	fullfile('projects','common')...,
	fullfile('projects','scripts')...,
	fullfile('projects','fmcomms2')...,
	fullfile('projects','adrv9361z7035', 'common')...,
    fullfile('projects','adrv9361z7035', lower(board))...,
    };

%% Add interfaces
% add clock interface
hRD.addClockInterface( ...
    'ClockConnection',   'util_ad9361_divclk/clk_out', ...
    'ResetConnection',   'util_ad9361_divclk_reset/peripheral_aresetn');
