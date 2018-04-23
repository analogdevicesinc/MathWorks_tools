function hRD = plugin_rd
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Call the common reference design definition function
hRD = AnalogDevices.adrv9364z7020.common.plugin_rd('box lvds', 'Rx & Tx');
AnalogDevices.adrv9364z7020.ccbox_lvds.rx_tx.add_rx_tx_io(hRD);