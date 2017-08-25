function hRD = plugin_rd
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Call the common reference design definition function
hRD = AnalogDevices.RFSOM2.common.plugin_rd('BOX Modem', 'Rx & Tx');
AnalogDevices.RFSOM2.ccbox_modem.rx_tx.add_rx_tx_io(hRD);