
source $ad_hdl_dir/projects/adrv9361z7035/common/adrv9361z7035_bd.tcl
source $ad_hdl_dir/projects/adrv9361z7035/common/ccfmc_bd.tcl

cfg_ad9361_interface LVDS

create_bd_port -dir O sys_cpu_clk_out
ad_connect  sys_cpu_clk sys_cpu_clk_out

ad_ip_parameter axi_ad9361 CONFIG.ADC_INIT_DELAY 29

# Add external pin for EN_AGC
create_bd_port -dir O gpio_en_agc

# Add external pins for CTRL_IN
create_bd_port -from 0 -to 7 -dir I gpio_status

# Add external pins for CTRL_OUT
create_bd_port -from 0 -to 3 -dir O gpio_ctl