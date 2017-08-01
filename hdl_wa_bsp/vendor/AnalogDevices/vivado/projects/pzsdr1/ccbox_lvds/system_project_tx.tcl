set ad_hdl_dir    	[pwd]
set ad_phdl_dir   	[pwd]
set proj_dir		$ad_hdl_dir/projects/pzsdr1/ccbox_lvds

source $ad_hdl_dir/projects/scripts/adi_project.tcl 
source $ad_hdl_dir/projects/scripts/adi_board.tcl 

set p_device "xc7z020clg400-1"
adi_project_create pzsdr1_ccbox_lvds $proj_dir config_tx.tcl
adi_project_files pzsdr1_ccbox_lvds [list \
  "$ad_hdl_dir/library/xilinx/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/pzsdr1/common/pzsdr1_constr.xdc" \
  "$ad_hdl_dir/projects/pzsdr1/common/pzsdr1_constr_lvds.xdc" \
  "$ad_hdl_dir/projects/pzsdr1/common/ccbox_constr.xdc" \
  "system_top.v" ]

adi_project_run pzsdr1_ccbox_lvds

# Copy the boot file to the root directory
file copy -force $proj_dir/boot $ad_hdl_dir/boot


