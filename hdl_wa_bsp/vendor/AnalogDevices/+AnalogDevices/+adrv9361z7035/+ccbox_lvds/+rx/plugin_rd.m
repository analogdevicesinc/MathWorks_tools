function hRD = plugin_rd
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Call the common reference design definition function
hRD = AnalogDevices.adrv9361z7035.common.plugin_rd('box lvds', 'Rx');
AnalogDevices.adrv9361z7035.ccbox_lvds.rx.add_rx_io(hRD);