set ad_hdl_dir    	[pwd]
set proj_dir		$ad_hdl_dir/projects/adrv9371x/zc706

source $proj_dir/config_prj.tcl
source $ad_hdl_dir/projects/adrv9371x/common/config_rxtx.tcl

regenerate_bd_layout
