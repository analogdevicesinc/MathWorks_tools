function hRD = plugin_rd
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Call the common reference design definition function
hRD = AnalogDevices.RFSOM2.common.plugin_rd('FMC LVDS', 'Rx');
AnalogDevices.RFSOM2.ccfmc_lvds.rx.add_rx_io(hRD);