function hRD = plugin_rd(board, design)
% Reference design definition

% Construct reference design object
hRD = hdlcoder.ReferenceDesign('SynthesisTool', 'Xilinx Vivado');

% This is the base reference design that other RDs can build upon
hRD.ReferenceDesignName = sprintf('ADRV9009 %s Base System (Vivado 2017.4)', upper(board));

% Determine the board name based on the design
hRD.BoardName = sprintf('AnalogDevices ADRV9009 %s (%s)', upper(board), design);

% Tool information
hRD.SupportedToolVersion = {'2017.4'};

% Get the root directory
rootDir = fileparts(strtok(mfilename('fullpath'), '+'));

% Design files are shared
hRD.SharedRD = true;
hRD.SharedRDFolder = fullfile(rootDir, 'vivado');

%% Add custom design files
% add custom Vivado design
switch(upper(design))
	case 'RX'
		hRD.addCustomVivadoDesign( ...
			'CustomBlockDesignTcl', fullfile('projects', 'adrv9009', lower(board), 'system_project_rx.tcl'), ...
			'CustomTopLevelHDL',    fullfile('projects', 'adrv9009', lower(board), 'system_top.v'));
	case 'TX'
		hRD.addCustomVivadoDesign( ...
			'CustomBlockDesignTcl', fullfile('projects', 'adrv9009', lower(board), 'system_project_tx.tcl'), ...
			'CustomTopLevelHDL',    fullfile('projects', 'adrv9009', lower(board), 'system_top.v'));
% 	case 'RX & TX'
% 		hRD.addCustomVivadoDesign( ...
% 			'CustomBlockDesignTcl', fullfile('projects', 'adrv9009', lower(board), 'system_project_rx_tx.tcl'), ...
% 			'CustomTopLevelHDL',    fullfile('projects', 'adrv9009', lower(board), 'system_top.v'));
	otherwise
		hRD.addCustomVivadoDesign( ...
			'CustomBlockDesignTcl', fullfile('projects', 'adrv9009', lower(board), 'system_project.tcl'), ...
			'CustomTopLevelHDL',    fullfile('projects', 'adrv9009', lower(board), 'system_top.v'));
end	

hRD.BlockDesignName = 'system';	
	
% custom constraint files
hRD.CustomConstraints = {...
    fullfile('projects', 'adrv9009', lower(board), 'system_constr.xdc'), ...
    fullfile('projects', 'common', lower(board), sprintf('%s_system_constr.xdc', lower(board))), ...
    };

% custom source files
hRD.CustomFiles = {...
    fullfile('projects')...,
	fullfile('library')...,
    };	
	
%% Add interfaces
% add clock interface
switch(upper(design))
    case 'RX'
        hRD.addClockInterface( ...
            'ClockConnection',   'axi_adrv9009_rx_clkgen/clk_0', ...
            'ResetConnection',   'sys_rstgen/peripheral_aresetn');
    case 'TX'
        hRD.addClockInterface( ...
            'ClockConnection',   'axi_adrv9009_tx_clkgen/clk_0', ...
            'ResetConnection',   'sys_rstgen/peripheral_aresetn');
%     case 'RX & TX'
%         hRD.addClockInterface( ...
%             'ClockConnection',   'util_ad9361_divclk/clk_0', ...
%             'ResetConnection',   'util_ad9361_divclk_reset/peripheral_aresetn');
%     case 'OBS'
%         hRD.addClockInterface( ...
%             'ClockConnection',   'axi_adrv9009_rx_os_clkgen/clk_0', ...
%             'ResetConnection',   'sys_rstgen/peripheral_aresetn');
    otherwise
        error('Unknown reference design');
end
	
