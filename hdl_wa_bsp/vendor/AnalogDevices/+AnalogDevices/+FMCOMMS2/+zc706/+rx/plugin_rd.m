function hRD = plugin_rd
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Call the common reference design definition function
hRD = AnalogDevices.FMCOMMS2.common.plugin_rd('ZC706', 'Rx');
AnalogDevices.FMCOMMS2.zc706.rx.add_rx_io(hRD);