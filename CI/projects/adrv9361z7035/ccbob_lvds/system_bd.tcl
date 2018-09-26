
source $ad_hdl_dir/projects/adrv9361z7035/common/adrv9361z7035_bd.tcl
source $ad_hdl_dir/projects/adrv9361z7035/common/ccbob_bd.tcl

cfg_ad9361_interface LVDS

ad_ip_parameter axi_ad9361 CONFIG.ADC_INIT_DELAY 29

