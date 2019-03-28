function hRD = plugin_rd_rxtx
% Reference design definition

% Call the common reference design definition function
hRD = AnalogDevices.adrv9361z7035.common.plugin_rd('ccfmc_lvds','Rx & Tx');
AnalogDevices.adrv9361z7035.common.add_io(hRD, 'Rx & Tx', 'ccfmc_lvds');
