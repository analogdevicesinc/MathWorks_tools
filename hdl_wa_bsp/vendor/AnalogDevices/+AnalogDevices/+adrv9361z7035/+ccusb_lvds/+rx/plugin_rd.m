function hRD = plugin_rd
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Call the common reference design definition function
hRD = AnalogDevices.adrv9361z7035.common.plugin_rd('usb lvds', 'Rx');
AnalogDevices.adrv9361z7035.ccusb_lvds.rx.add_rx_io(hRD);