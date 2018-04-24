function hB = plugin_board(board, design)
% Use Plugin API to create board plugin object

%   Copyright 2015 The MathWorks, Inc.

hB = hdlcoder.Board;

% Target Board Information
hB.BoardName    = sprintf('AnalogDevices adrv9361z7035 %s (%s)', board, design);

% FPGA Device
hB.FPGAVendor   = 'Xilinx';
hB.FPGAFamily   = 'Zynq';

% Determine the device based on the board
hB.FPGADevice   = sprintf('xc7%s', 'z035i');
hB.FPGAPackage  = 'fbg676';
hB.FPGASpeed    = '-2L';


% Tool Info
hB.SupportedTool = {'Xilinx Vivado'};

% FPGA JTAG chain position
hB.JTAGChainPosition = 2;

%% Add interfaces
% Standard "External Port" interface

