function hB = plugin_board(board, design)
% Use Plugin API to create board plugin object

%   Copyright 2015 The MathWorks, Inc.

hB = hdlcoder.Board;

% Target Board Information
hB.BoardName    = sprintf('AnalogDevices RFSOM1 %s (%s)', upper(board), design);

% FPGA Device
hB.FPGAVendor   = 'Xilinx';
hB.FPGAFamily   = 'Zynq';

% Determine the device based on the board
switch(upper(board))
	case 'BREAKOUT CMOS'
		hB.FPGADevice   = sprintf('xc7%s', 'z020');
		hB.FPGAPackage  = 'clg400';
		hB.FPGASpeed    = '-1';
	case 'BREAKOUT LVDS'
		hB.FPGADevice   = sprintf('xc7%s', 'z020');
		hB.FPGAPackage  = 'clg400';
		hB.FPGASpeed    = '-1';
	otherwise
		hB.FPGADevice   = sprintf('xc7%s', 'z020');
		hB.FPGAPackage  = 'clg400';
		hB.FPGASpeed    = '-1';
end

% Tool Info
hB.SupportedTool = {'Xilinx Vivado'};

% FPGA JTAG chain position
hB.JTAGChainPosition = 2;

%% Add interfaces
% Standard "External Port" interface

