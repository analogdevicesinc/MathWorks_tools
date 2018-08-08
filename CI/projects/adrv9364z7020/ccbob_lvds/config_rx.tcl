set ad_hdl_dir    	[pwd]
set proj_dir		$ad_hdl_dir/projects/adrv9364z7020/ccbob_lvds

source $proj_dir/config_prj.tcl
source $ad_hdl_dir/projects/adrv9364z7020/common/config_rx.tcl

regenerate_bd_layout