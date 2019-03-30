function hRD = plugin_rd_rx
% Reference design definition

% Call the common reference design definition function
hRD = AnalogDevices.adrv9364z7020.common.plugin_rd('ccbob_lvds','Rx');
AnalogDevices.adrv9364z7020.common.add_io(hRD, 'Rx');
