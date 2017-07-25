set ad_hdl_dir    	[pwd]
set ad_phdl_dir   	[pwd]
set proj_dir		$ad_hdl_dir/projects/fmcomms2/zed

source $ad_hdl_dir/projects/scripts/adi_project.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

adi_project_create fmcomms2_zed $proj_dir config_rx.tcl

adi_project_files fmcomms2_zed [list \
  "system_top.v" \
  "system_constr.xdc"\
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/common/zed/zed_system_constr.xdc" ]

adi_project_run fmcomms2_zed

# Copy the boot file to the root directory
file copy -force $proj_dir/boot $ad_hdl_dir/boot

