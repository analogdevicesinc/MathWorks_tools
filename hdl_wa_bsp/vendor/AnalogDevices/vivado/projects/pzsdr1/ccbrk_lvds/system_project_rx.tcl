set ad_hdl_dir    	[pwd]
set ad_phdl_dir   	[pwd]
set proj_dir		$ad_hdl_dir/projects/pzsdr1/ccbrk_lvds

source $ad_hdl_dir/projects/scripts/adi_project.tcl 
source $ad_hdl_dir/projects/scripts/adi_board.tcl 

set p_device "xc7z020clg400-1"
adi_project_create pzsdr1_ccbrk_lvds $proj_dir config_rx.tcl
adi_project_files pzsdr1_ccbrk_lvds [list \
  "$ad_hdl_dir/library/xilinx/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/pzsdr1/common/pzsdr1_constr.xdc" \
  "$ad_hdl_dir/projects/pzsdr1/common/pzsdr1_constr_lvds.xdc" \
  "$ad_hdl_dir/projects/pzsdr1/common/ccbrk_constr.xdc" \
  "system_top.v" ]

set_property is_enabled false [get_files  *axi_gpreg_constr.xdc]
adi_project_run pzsdr1_ccbrk_lvds
# Copy the boot file to the root directory
file copy -force $proj_dir/boot $ad_hdl_dir/boot


