set ad_hdl_dir    	[pwd]
set ad_phdl_dir   	[pwd]
set proj_dir		$ad_hdl_dir/projects/adrv9364z7020/adrv9364z7020_ccbox_lvds

source $ad_hdl_dir/projects/scripts/adi_project.tcl 
source $ad_hdl_dir/projects/scripts/adi_board.tcl 

set p_device "xc7z020clg400-1"
adi_project_xilinx adrv9364z7020_ccbox_lvds
adi_project_create adrv9364z7020_ccbox_lvds $proj_dir config_tx.tcl
adi_project_files adrv9364z7020_ccbox_lvds [list \
  "$ad_hdl_dir/library/xilinx/common/ad_iobuf.v" \
  "$ad_hdl_dir/library/common/ad_adl5904_rst.v" \
  "$ad_hdl_dir/projects/adrv9364z7020_ccbox_lvds/common/adrv9364z7020_constr.xdc" \
  "$ad_hdl_dir/projects/adrv9364z7020_ccbox_lvds/common/adrv9364z7020_constr_lvds.xdc" \
  "$ad_hdl_dir/projects/adrv9364z7020_ccbox_lvds/common/ccbox_constr.xdc" \
  "system_top.v" ]

adi_project_run adrv9364z7020_ccbox_lvds
source $ad_hdl_dir/library/axi_ad9361/axi_ad9361_delay.tcl

# Copy the boot file to the root directory
file copy -force $proj_dir/boot $ad_hdl_dir/boot


