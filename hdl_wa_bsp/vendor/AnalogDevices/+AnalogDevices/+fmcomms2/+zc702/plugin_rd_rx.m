function hRD = plugin_rd_rx
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

% Call the common reference design definition function
hRD = AnalogDevices.fmcomms2.common.plugin_rd('ZC702', 'Rx');
AnalogDevices.fmcomms2.zc702.add_io(hRD,'Rx');