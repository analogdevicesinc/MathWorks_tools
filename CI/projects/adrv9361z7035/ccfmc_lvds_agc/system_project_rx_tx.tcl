set ad_hdl_dir    	[pwd]
set ad_phdl_dir   	[pwd]
set proj_dir		$ad_hdl_dir/projects/adrv9361z7035/ccfmc_lvds_agc

source $ad_hdl_dir/projects/scripts/adi_project.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

set p_device "xc7z035ifbg676-2L"
adi_project_xilinx adrv9361z7035_ccfmc_lvds_agc $proj_dir config_rx_tx.tcl
adi_project_files adrv9361z7035_ccfmc_lvds_agc [list \
  "$ad_hdl_dir/library/xilinx/common/ad_iobuf.v" \
  "$ad_hdl_dir/library/common/ad_adl5904_rst.v" \
  "$ad_hdl_dir/projects/adrv9361z7035/common/adrv9361z7035_constr.xdc" \
  "$ad_hdl_dir/projects/adrv9361z7035/common/adrv9361z7035_constr_lvds.xdc" \
  "$ad_hdl_dir/projects/adrv9361z7035/common/ccfmc_constr.xdc" \
  "system_top.v" ]

adi_project_run adrv9361z7035_ccfmc_lvds_agc
#source $ad_hdl_dir/library/analog.com_user_axi_ad9361_1.0/axi_ad9361_delay.tcl
# Copy the boot file to the root directory
file copy -force $proj_dir/boot $ad_hdl_dir/boot

# Add external pin for EN_AGC
#create_bd_port -dir O gpio_en_agc
