function hRD = plugin_rd_tx
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Call the common reference design definition function
hRD = AnalogDevices.adrv9371x.common.plugin_rd('ZCU102', 'Tx');
AnalogDevices.adrv9371x.zcu102.add_io(hRD, 'Tx');
