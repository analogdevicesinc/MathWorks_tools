# Create the by 4 AD9361 clock divider 
create_bd_cell -type ip -vlnv analog.com:user:util_clkdiv:1.0 util_clkdiv_0
connect_bd_net -net [get_bd_nets axi_ad9361_clk] [get_bd_pins util_clkdiv_0/clk] [get_bd_pins axi_ad9361/l_clk]

# Add an extra reset generator
set sys_rstgen1 [create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0]
set_property -dict [list CONFIG.C_EXT_RST_WIDTH {1}] $sys_rstgen1
connect_bd_net -net [get_bd_nets sys_ps7_FCLK_RESET0_N] [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins sys_ps7/FCLK_RESET0_N]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins util_clkdiv_0/clk_out]

# Add 1 extra AXI master ports to the interconnect
set_property -dict [list CONFIG.NUM_MI {11}] [get_bd_cells axi_cpu_interconnect]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins axi_cpu_interconnect/M10_ACLK] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins axi_cpu_interconnect/M10_ARESETN]

# Delete interrupt line 11
delete_bd_objs [get_bd_ports ps_intr_11]
