function hRD = plugin_rd
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Call the common reference design definition function
hRD = AnalogDevices.PicoZedSDR.common.plugin_rd('FMC', 'Rx');
AnalogDevices.PicoZedSDR.ccfmc.rx.add_rx_io(hRD);