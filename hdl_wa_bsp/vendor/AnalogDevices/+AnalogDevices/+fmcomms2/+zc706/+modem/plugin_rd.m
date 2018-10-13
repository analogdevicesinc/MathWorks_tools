function hRD = plugin_rd
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Call the common reference design definition function
hRD = AnalogDevices.fmcomms2.common.plugin_rd('zc706', 'modem');
AnalogDevices.adrv9361z7035.ccbox_lvds.modem.add_rx_tx_io(hRD);
