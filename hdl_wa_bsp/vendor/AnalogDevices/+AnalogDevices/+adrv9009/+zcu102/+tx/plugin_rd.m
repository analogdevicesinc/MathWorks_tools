function hRD = plugin_rd
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Call the common reference design definition function
hRD = AnalogDevices.adrv9009.common.plugin_rd('ZCU102', 'Tx');
AnalogDevices.adrv9009.zcu102.tx.add_tx_io(hRD);