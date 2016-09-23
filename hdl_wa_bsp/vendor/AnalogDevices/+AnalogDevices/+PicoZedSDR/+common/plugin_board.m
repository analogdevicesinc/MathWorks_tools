function hB = plugin_board(board, design)
% Use Plugin API to create board plugin object

%   Copyright 2015 The MathWorks, Inc.

hB = hdlcoder.Board;

% Target Board Information
hB.BoardName    = sprintf('AnalogDevices PicoZedSDR %s (%s)', upper(board), design);

% FPGA Device
hB.FPGAVendor   = 'Xilinx';
hB.FPGAFamily   = 'Zynq';

% Determine the device based on the board
switch(upper(board))
	case 'FMC'
		hB.FPGADevice   = sprintf('xc7%s', 'z035i');
		hB.FPGAPackage  = 'fbg676';
		hB.FPGASpeed    = '-2L';
	case 'PCI'
		hB.FPGADevice   = sprintf('xc7%s', 'z035i');
		hB.FPGAPackage  = 'fbg676';
		hB.FPGASpeed    = '-2L';
	case 'BREAKOUT'
		hB.FPGADevice   = sprintf('xc7%s', 'z035i');
		hB.FPGAPackage  = 'fbg676';
		hB.FPGASpeed    = '-2L';
	otherwise
		hB.FPGADevice   = sprintf('xc7%s', 'z035i');
		hB.FPGAPackage  = 'fbg676';
		hB.FPGASpeed    = '-2L';
end

% Tool Info
hB.SupportedTool = {'Xilinx Vivado'};

% FPGA JTAG chain position
hB.JTAGChainPosition = 2;

%% Add interfaces
% Standard "External Port" interface

