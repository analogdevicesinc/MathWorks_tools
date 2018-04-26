set ad_hdl_dir    	[pwd]
set proj_dir		$ad_hdl_dir/projects/adrv9364z7020/ccbox_lvds

source $proj_dir/config_prj.tcl
source $ad_hdl_dir/projects/adrv9364z7020/common/config_rx.tcl
source $ad_hdl_dir/projects/adrv9364z7020/common/config_tx.tcl

regenerate_bd_layout