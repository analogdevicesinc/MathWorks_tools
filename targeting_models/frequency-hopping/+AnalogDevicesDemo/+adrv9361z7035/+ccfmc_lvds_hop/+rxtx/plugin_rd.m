function hRD = plugin_rd
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Call the common reference design definition function
hRD = AnalogDevicesDemo.adrv9361z7035.common.plugin_rd('ccfmc_lvds_hop', 'Rx & Tx');
AnalogDevicesDemo.adrv9361z7035.ccfmc_lvds_hop.rxtx.add_rx_tx_io(hRD);