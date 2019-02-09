function hRD = plugin_rd_rx
% Reference design definition

% Call the common reference design definition function
hRD = AnalogDevices.adrv9371x.common.plugin_rd('ZC706', 'Rx');
AnalogDevices.adrv9371x.zc706.add_io(hRD, 'Rx');
