function hRD = plugin_rd
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Call the common reference design definition function
hRD = AnalogDevicesAGCDemo.adrv9361z7035.common.plugin_rd('fmc lvds agc', 'Rx');
AnalogDevicesAGCDemo.adrv9361z7035.ccfmc_lvds_agc.rx.add_rx_io(hRD);