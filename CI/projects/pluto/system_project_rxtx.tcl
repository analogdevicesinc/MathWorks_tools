set ad_hdl_dir    	[pwd]
set ad_phdl_dir   	[pwd]
set proj_dir		$ad_hdl_dir/projects/pluto

source $ad_hdl_dir/projects/scripts/adi_project.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

adi_project_xilinx pluto $proj_dir config_rxtx.tcl

adi_project_files pluto [list \
  "system_top.v" \
  "system_constr.xdc"\
  "$ad_hdl_dir/library/xilinx/common/ad_iobuf.v" ]

adi_project_run pluto
#source $ad_hdl_dir/library/analog.com_user_axi_ad9361_1.0/axi_ad9361_delay.tcl

# Copy the boot file to the root directory
#file copy -force $proj_dir/boot $ad_hdl_dir/boot