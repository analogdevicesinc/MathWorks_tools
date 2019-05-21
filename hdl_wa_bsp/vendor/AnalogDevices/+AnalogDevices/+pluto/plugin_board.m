function hB = plugin_board()
% Use Plugin API to create board plugin object

%   Copyright 2015 The MathWorks, Inc.

hB = hdlcoder.Board;

% Target Board Information
hB.BoardName    = 'AnalogDevices ADALM-PLUTO';

% FPGA Device
hB.FPGAVendor   = 'Xilinx';
hB.FPGAFamily   = 'Zynq';

% Determine the device based on the board
hB.FPGADevice   = sprintf('xc7%s', 'z010');
hB.FPGAPackage  = 'clg225';
hB.FPGASpeed    = '-1';	

% Tool Info
hB.SupportedTool = {'Xilinx Vivado'};

% FPGA JTAG chain position
hB.JTAGChainPosition = 2;

%% Add interfaces
% Standard "External Port" interface

