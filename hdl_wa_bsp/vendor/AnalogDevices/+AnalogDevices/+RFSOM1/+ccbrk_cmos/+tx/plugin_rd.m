function hRD = plugin_rd
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Call the common reference design definition function
hRD = AnalogDevices.RFSOM1.common.plugin_rd('BREAKOUT CMOS', 'Tx');
AnalogDevices.RFSOM1.ccbrk_cmos.tx.add_tx_io(hRD);