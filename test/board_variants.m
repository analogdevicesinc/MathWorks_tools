function r = board_variants
% Board plugin registration file
% 1. Any registration file with this name on MATLAB path will be picked up
% 2. Registration file returns a cell array pointing to the location of
%    the board plugins
% 3. Board plugin must be a package folder accessible from MATLAB path,
%    and contains a board definition file

%   Copyright 2012-2013 The MathWorks, Inc.

r = { ...
    'AnalogDevices.pluto.plugin_rd_rxtx', ...
    ...
    'AnalogDevices.fmcomms2.zed.plugin_rd_rx', ...
    'AnalogDevices.fmcomms2.zed.plugin_rd_rxtx', ...
    'AnalogDevices.fmcomms2.zed.plugin_rd_tx', ...
    ...
    'AnalogDevices.fmcomms2.zc702.plugin_rd_rx', ...
    'AnalogDevices.fmcomms2.zc702.plugin_rd_rxtx', ...
    'AnalogDevices.fmcomms2.zc702.plugin_rd_tx', ...
    ...
    'AnalogDevices.fmcomms2.zc706.plugin_rd_rx', ...
    'AnalogDevices.fmcomms2.zc706.plugin_rd_rxtx', ...
    'AnalogDevices.fmcomms2.zc706.plugin_rd_tx', ...
     ...
     'AnalogDevices.fmcomms5.zc702.plugin_rd_rx', ...
     'AnalogDevices.fmcomms5.zc702.plugin_rd_rxtx', ...
     'AnalogDevices.fmcomms5.zc702.plugin_rd_tx', ...
     ...
     'AnalogDevices.fmcomms5.zc706.plugin_rd_rx', ...
     'AnalogDevices.fmcomms5.zc706.plugin_rd_rxtx', ...
     'AnalogDevices.fmcomms5.zc706.plugin_rd_tx', ...
     ...
     'AnalogDevices.adrv9364z7020.ccbob_cmos.plugin_rd_rx', ...
     'AnalogDevices.adrv9364z7020.ccbob_cmos.plugin_rd_rxtx', ...
     'AnalogDevices.adrv9364z7020.ccbob_cmos.plugin_rd_tx', ...
     ...
     'AnalogDevices.adrv9364z7020.ccbob_lvds.plugin_rd_rx', ...
     'AnalogDevices.adrv9364z7020.ccbob_lvds.plugin_rd_rxtx', ...
     'AnalogDevices.adrv9364z7020.ccbob_lvds.plugin_rd_tx', ...
     ...
     'AnalogDevices.adrv9364z7020.ccbox_lvds.plugin_rd_rx', ...
     'AnalogDevices.adrv9364z7020.ccbox_lvds.plugin_rd_rxtx', ...
     'AnalogDevices.adrv9364z7020.ccbox_lvds.plugin_rd_tx', ...
     ...
     'AnalogDevices.adrv9361z7035.ccbob_cmos.plugin_rd_rx', ...
     'AnalogDevices.adrv9361z7035.ccbob_cmos.plugin_rd_rxtx', ...
     'AnalogDevices.adrv9361z7035.ccbob_cmos.plugin_rd_tx', ...
     ...
     'AnalogDevices.adrv9361z7035.ccbob_lvds.plugin_rd_rx', ...
     'AnalogDevices.adrv9361z7035.ccbob_lvds.plugin_rd_rxtx', ...
     'AnalogDevices.adrv9361z7035.ccbob_lvds.plugin_rd_tx', ...
     ...
     'AnalogDevices.adrv9361z7035.ccbox_lvds.plugin_rd_rx', ...
     'AnalogDevices.adrv9361z7035.ccbox_lvds.plugin_rd_rxtx', ...
     'AnalogDevices.adrv9361z7035.ccbox_lvds.plugin_rd_tx', ...
     ...
     'AnalogDevices.adrv9361z7035.ccfmc_lvds.plugin_rd_rx', ...
     'AnalogDevices.adrv9361z7035.ccfmc_lvds.plugin_rd_rxtx', ...
     'AnalogDevices.adrv9361z7035.ccfmc_lvds.plugin_rd_tx' ...
     ...
     'AnalogDevices.adrv9371x.zcu102.plugin_rd_rx', ...
     'AnalogDevices.adrv9371x.zcu102.plugin_rd_rxtx', ...
     'AnalogDevices.adrv9371x.zcu102.plugin_rd_tx', ...
     'AnalogDevices.adrv9371x.zc706.plugin_rd_rx', ...
     'AnalogDevices.adrv9371x.zc706.plugin_rd_rxtx', ...
     'AnalogDevices.adrv9371x.zc706.plugin_rd_tx', ...
     ...
     'AnalogDevices.adrv9009.zcu102.plugin_rd_rx', ...
     'AnalogDevices.adrv9009.zcu102.plugin_rd_rxtx', ...
     'AnalogDevices.adrv9009.zcu102.plugin_rd_tx' ...
    };
end
% LocalWords:  Zynq ZC
