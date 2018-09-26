set ad_hdl_dir    	[pwd]
set proj_dir		$ad_hdl_dir/projects/adrv9361z7035/ccbob_lvds

source $proj_dir/config_prj.tcl
source $ad_hdl_dir/projects/adrv9361z7035/common/config_rx.tcl

regenerate_bd_layout