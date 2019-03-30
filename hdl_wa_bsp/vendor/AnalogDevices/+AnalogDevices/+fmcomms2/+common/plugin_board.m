function hB = plugin_board(board)
% Use Plugin API to create board plugin object

%   Copyright 2015 The MathWorks, Inc.

hB = hdlcoder.Board;

% Target Board Information
hB.BoardName    = sprintf('AnalogDevices FMCOMMS2/3 %s', upper(board));

% FPGA Device
hB.FPGAVendor   = 'Xilinx';
hB.FPGAFamily   = 'Zynq';

% Determine the device based on the board
switch(upper(board))
	case 'ZC706'
		hB.FPGADevice   = sprintf('xc7%s', 'z045');
		hB.FPGAPackage  = 'ffg900';
		hB.FPGASpeed    = '-2';
	case 'ZC702'
		hB.FPGADevice   = sprintf('xc7%s', 'z020');
		hB.FPGAPackage  = 'clg484';
		hB.FPGASpeed    = '-1';	
	case 'ZED'
		hB.FPGADevice   = sprintf('xc7%s', 'z020');
		hB.FPGAPackage  = 'clg484';
		hB.FPGASpeed    = '-1';	
	otherwise
		hB.FPGADevice   = sprintf('xc7%s', 'z045');
		hB.FPGAPackage  = 'ffg900';
		hB.FPGASpeed    = '-2';
end

% Tool Info
hB.SupportedTool = {'Xilinx Vivado'};

% FPGA JTAG chain position
hB.JTAGChainPosition = 2;

%% Add interfaces
% Standard "External Port" interface

