function hRD = plugin_rd(board, design)
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Construct reference design object
hRD = hdlcoder.ReferenceDesign('SynthesisTool', 'Xilinx Vivado');

% Create the reference design for the SOM-only
% This is the base reference design that other RDs can build upon
hRD.ReferenceDesignName = sprintf('RFSOM2 %s Base System (Vivado 2016.2)', upper(board));

% Determine the board name based on the design
hRD.BoardName = sprintf('AnalogDevices RFSOM2 %s (%s)', upper(board), design);

% Tool information
hRD.SupportedToolVersion = {'2016.2'};

% Get the root directory
rootDir = fileparts(strtok(mfilename('fullpath'), '+'));

% Design files are shared
hRD.SharedRD = true;
hRD.SharedRDFolder = fullfile(rootDir, 'vivado');

switch(upper(board))
	case 'BOX LVDS'
		board = 'ccbox_lvds';
	case 'BOX MODEM'
		board = 'ccbox_modem';	
	case 'BREAKOUT LVDS'
		board = 'ccbrk_lvds';
	case 'BREAKOUT CMOS'
		board = 'ccbrk_cmos';
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
			'CustomBlockDesignTcl', fullfile('projects', 'pzsdr2', lower(board), 'system_project_rx.tcl'), ...
			'CustomTopLevelHDL',    fullfile('projects', 'pzsdr2', lower(board), 'system_top.v'));
	case 'TX'
		hRD.addCustomVivadoDesign( ...
			'CustomBlockDesignTcl', fullfile('projects', 'pzsdr2', lower(board), 'system_project_tx.tcl'), ...
			'CustomTopLevelHDL',    fullfile('projects', 'pzsdr2', lower(board), 'system_top.v'));
	case 'RX & TX'
		hRD.addCustomVivadoDesign( ...
			'CustomBlockDesignTcl', fullfile('projects', 'pzsdr2', lower(board), 'system_project_rx_tx.tcl'), ...
			'CustomTopLevelHDL',    fullfile('projects', 'pzsdr2', lower(board), 'system_top.v'));		
	otherwise
		hRD.addCustomVivadoDesign( ...
			'CustomBlockDesignTcl', fullfile('projects', 'pzsdr2', lower(board), 'system_project.tcl'), ...
			'CustomTopLevelHDL',    fullfile('projects', 'pzsdr2', lower(board), 'system_top.v'));
end	

hRD.BlockDesignName = 'system';	
	
% custom constraint files
board_type = strsplit(board,'_');
hRD.CustomConstraints = {...
    fullfile('projects', 'pzsdr2', 'common', strcat(board_type{1}, '_constr.xdc')), ...
	fullfile('projects', 'pzsdr2', 'common', 'pzsdr2_constr.xdc'), ...
	fullfile('projects', 'pzsdr2', 'common', strcat('pzsdr2_constr_', board_type{2}, '.xdc')), ...
    };

% custom source files
hRD.CustomFiles = {...
	fullfile('library')...,
	fullfile('projects','common')...,
	fullfile('projects','scripts')...,
	fullfile('projects','fmcomms2')...,
	fullfile('projects','pzsdr2', 'common')...,
    fullfile('projects','pzsdr2', lower(board))...,
    };	
	
%% Add interfaces
% add clock interface
hRD.addClockInterface( ...
    'ClockConnection',   'clkdiv/clk_out', ...
    'ResetConnection',   'clkdiv_reset/peripheral_aresetn');
	
