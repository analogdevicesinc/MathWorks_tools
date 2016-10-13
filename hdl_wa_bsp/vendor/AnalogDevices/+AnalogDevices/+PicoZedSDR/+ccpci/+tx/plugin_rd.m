function hRD = plugin_rd
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Call the common reference design definition function
hRD = AnalogDevices.PicoZedSDR.common.plugin_rd('PCI', 'Tx');
AnalogDevices.PicoZedSDR.ccpci.tx.add_tx_io(hRD);