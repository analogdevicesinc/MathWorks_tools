set ad_hdl_dir    	[pwd]
set ad_phdl_dir   	[pwd]
set proj_dir		$ad_hdl_dir/projects/adrv9361z7035/ccbox_lvds

source $ad_hdl_dir/projects/scripts/adi_project.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

set p_device "xc7z035ifbg676-2L"
adi_project_xilinx adrv9361z7035_ccbox_lvds $proj_dir
adi_project_files adrv9361z7035_ccbox_lvds [list \
  "$ad_hdl_dir/library/xilinx/common/ad_iobuf.v" \
  "$ad_hdl_dir/library/common/ad_adl5904_rst.v" \
  "$ad_hdl_dir/projects/adrv9361z7035/common/adrv9361z7035_constr.xdc" \
  "$ad_hdl_dir/projects/adrv9361z7035/common/adrv9361z7035_constr_lvds.xdc" \
  "$ad_hdl_dir/projects/adrv9361z7035/common/ccbox_constr.xdc" \
  "system_top.v" ]

adi_project_run adrv9361z7035_ccbox_lvds

# Copy the boot file to the root directory
file copy -force $proj_dir/boot $ad_hdl_dir/boot