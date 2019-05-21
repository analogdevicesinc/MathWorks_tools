function hRD = plugin_rd_rxtx
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Call the common reference design definition function
hRD = AnalogDevices.pluto.plugin_rd('Rx & Tx');
AnalogDevices.pluto.add_io(hRD,'Rx & Tx');