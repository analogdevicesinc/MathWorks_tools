### NEED TO COPY IP CORE MANUALLY (MATHWORKS BUG?)
puts [pwd]
cd ..
exec cp {ipcore/HDL_DUT_ip_v1_0/HDL_DUT_ip_v1_0.zip} vivado_ip_prj/ipcore/
cd vivado_ip_prj
update_ip_catalog
###

#source ../../scripts/adi_env.tcl

set ad_hdl_dir    	[pwd]
set ad_phdl_dir   	[pwd]
set proj_dir		$ad_hdl_dir/projects/adrv9009/zcu102

source $ad_hdl_dir/projects/scripts/adi_project.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

adi_project_xilinx adrv9009_zcu102 $proj_dir config_rx_tx.tcl
adi_project_files adrv9009_zcu102 [list \
  "system_top.v" \
  "system_constr.xdc"\
  "$ad_hdl_dir/library/xilinx/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/common/zcu102/zcu102_system_constr.xdc" ]

adi_project_run adrv9009_zcu102

# Copy the boot file to the root directory
file copy -force $proj_dir/boot $ad_hdl_dir/boot