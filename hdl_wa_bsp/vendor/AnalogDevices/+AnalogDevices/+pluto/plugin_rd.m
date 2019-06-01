function hRD = plugin_rd(design)
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Construct reference design object
hRD = hdlcoder.ReferenceDesign('SynthesisTool', 'Xilinx Vivado');

% Create the reference design for the SOM-only
% This is the base reference design that other RDs can build upon
hRD.ReferenceDesignName = sprintf('AnalogDevices ADALM-PLUTO (%s)', upper(design));

% Determine the board name based on the design
hRD.BoardName = 'AnalogDevices ADALM-PLUTO';

% Tool information
hRD.SupportedToolVersion = {'2018.2'};

% Get the root directory
rootDir = fileparts(strtok(mfilename('fullpath'), '+'));

% Design files are shared
hRD.SharedRD = true;
hRD.SharedRDFolder = fullfile(rootDir, 'vivado');

%% Add custom design files
% add custom Vivado design
hRD.addCustomVivadoDesign( ...
    'CustomBlockDesignTcl', fullfile('projects', 'pluto', 'system_project_rxtx.tcl'), ...
    'CustomTopLevelHDL',    fullfile('projects', 'pluto', 'system_top.v'));

hRD.BlockDesignName = 'system';	
	
% custom constraint files
hRD.CustomConstraints = {...
    fullfile('projects', 'pluto', 'system_constr.xdc'), ...
    ...%fullfile('projects', 'common', lower(board), sprintf('%s_system_constr.xdc', lower(board))), ...
    };

% custom source files
hRD.CustomFiles = {...
    fullfile('projects')...,
	fullfile('library')...,
    };

hRD.addParameter( ...
    'ParameterID',   'ref_design', ...
    'DisplayName',   'Reference Type', ...
    'DefaultValue',  design);

board = 'PLUTO';
hRD.addParameter( ...
    'ParameterID',   'fpga_board', ...
    'DisplayName',   'FPGA Boad', ...
    'DefaultValue',  upper(board));

hRD.addParameter( ...
    'ParameterID', 'dma', ...
    'DisplayName', 'DMA Mode', ...
    'DefaultValue', 'Stream',...
    'ParameterType',hdlcoder.ParameterType.Dropdown,...
    'Choice',{'Packetized', 'Stream'} );

%% Add interfaces
% add clock interface
% axi_ad9361/l_clk
% hRD.addClockInterface( ...
%     'ClockConnection',   'sys_ps7/FCLK_CLK0', ...
%     'ResetConnection',   'sys_rstgen/peripheral_aresetn');
hRD.addClockInterface( ...
    'ClockConnection',   'axi_ad9361/l_clk', ...
    'ResetConnection',   'proc_sys_reset_0/peripheral_aresetn'); % Added IP core
%     'ResetConnection',   'sys_rstgen/peripheral_aresetn');
	
