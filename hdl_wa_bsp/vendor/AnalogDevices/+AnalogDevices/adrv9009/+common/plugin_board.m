function hB = plugin_board(board, design)
% Use Plugin API to create board plugin object

%   Copyright 2015 The MathWorks, Inc.

hB = hdlcoder.Board;

% Target Board Information
hB.BoardName    = sprintf('AnalogDevices ADRV9009 %s (%s)', upper(board), design);

% FPGA Device
hB.FPGAVendor   = 'Xilinx';
hB.FPGAFamily   = 'Zynq';

% Determine the device based on the board
switch(upper(board))
	case 'ZCU102'
		hB.FPGADevice   = sprintf('xc%s', 'zu9eg');
		hB.FPGAPackage  = 'ffvb1156';
		hB.FPGASpeed    = '-2';
% 	otherwise
% 		hB.FPGADevice   = sprintf('xc7%s', 'z045');
% 		hB.FPGAPackage  = 'ffg900';
% 		hB.FPGASpeed    = '-2';
end

% Tool Info
hB.SupportedTool = {'Xilinx Vivado'};

% FPGA JTAG chain position
hB.JTAGChainPosition = 2;

%% Add interfaces
% Standard "External Port" interface

