function hRD = plugin_rd
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Call the common reference design definition function
hRD = AnalogDevices.fmcomms2.common.plugin_rd('ZED', 'Rx');
AnalogDevices.fmcomms2.zed.rx.add_rx_io(hRD);