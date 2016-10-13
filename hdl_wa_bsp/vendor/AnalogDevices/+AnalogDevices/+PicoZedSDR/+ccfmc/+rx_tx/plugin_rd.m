function hRD = plugin_rd
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Call the common reference design definition function
hRD = AnalogDevices.PicoZedSDR.common.plugin_rd('FMC', 'Rx & Tx');
AnalogDevices.PicoZedSDR.ccfmc.rx_tx.add_rx_tx_io(hRD);