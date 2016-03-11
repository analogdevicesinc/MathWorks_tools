function hRD = plugin_rd
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Call the common reference design definition function
hRD = AnalogDevices.FMCOMMS2.common.plugin_rd('ZED', 'Tx');
AnalogDevices.FMCOMMS2.zed.tx.add_tx_io(hRD);