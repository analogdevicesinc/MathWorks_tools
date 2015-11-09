# Disconnect the DAC UNPACK pins
disconnect_bd_net /axi_ad9361_clk [get_bd_pins util_dac_unpack/clk]
delete_bd_objs [get_bd_nets util_dac_unpack_dac_data_00]
delete_bd_objs [get_bd_nets util_dac_unpack_dac_data_01]
delete_bd_objs [get_bd_nets util_dac_unpack_dac_data_02]
delete_bd_objs [get_bd_nets util_dac_unpack_dac_data_03]
delete_bd_objs [get_bd_nets axi_ad9361_dac_valid_i0]
delete_bd_objs [get_bd_nets axi_ad9361_dac_valid_q0]
delete_bd_objs [get_bd_nets axi_ad9361_dac_valid_i1]
delete_bd_objs [get_bd_nets axi_ad9361_dac_valid_q1]

# Disconnect the DAC DMA pins
disconnect_bd_net /axi_ad9361_clk [get_bd_pins axi_ad9361_dac_dma/fifo_rd_clk]

# Create the by 4 AD9361 clock divider 
create_bd_cell -type ip -vlnv analog.com:user:util_clkdiv:1.0 util_clkdiv_0
connect_bd_net -net [get_bd_nets axi_ad9361_clk] [get_bd_pins util_clkdiv_0/clk] [get_bd_pins axi_ad9361/l_clk]

# Connect the open clock nets
connect_bd_net [get_bd_pins util_dac_unpack/clk] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out1] [get_bd_pins axi_ad9361_dac_dma/fifo_rd_clk] [get_bd_pins util_clkdiv_0/clk_out]

# Connect the ADC PACK valid signals together
connect_bd_net [get_bd_pins util_dac_unpack/dac_valid_00] [get_bd_pins util_dac_unpack/dac_valid_01]
connect_bd_net [get_bd_pins util_dac_unpack/dac_valid_00] [get_bd_pins util_dac_unpack/dac_valid_02]
connect_bd_net [get_bd_pins util_dac_unpack/dac_valid_00] [get_bd_pins util_dac_unpack/dac_valid_03]

# Add an extra reset generator
set sys_rstgen1 [create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0]
set_property -dict [list CONFIG.C_EXT_RST_WIDTH {1}] $sys_rstgen1
connect_bd_net -net [get_bd_nets sys_ps7_FCLK_RESET0_N] [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins sys_ps7/FCLK_RESET0_N]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins util_clkdiv_0/clk_out]

# Add 2 extra AXI master ports to the interconnect
set_property -dict [list CONFIG.NUM_MI {11}] [get_bd_cells axi_cpu_interconnect]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins axi_cpu_interconnect/M09_ACLK] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins axi_cpu_interconnect/M10_ACLK] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins axi_cpu_interconnect/M09_ARESETN]
connect_bd_net [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins axi_cpu_interconnect/M10_ARESETN]

# Delete interrupt line 11
delete_bd_objs [get_bd_ports ps_intr_11]

# Create a constant block
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0

# Connect the Tx FIFOs ports
ad_connect  axi_ad9361_clk sys_rfifo_0/dac_clk
ad_connect  axi_ad9361_clk sys_rfifo_1/dac_clk
ad_connect  axi_ad9361_clk sys_rfifo_2/dac_clk
ad_connect  axi_ad9361_clk sys_rfifo_3/dac_clk
ad_connect  sys_rfifo_0/dac_rdata axi_ad9361/dac_data_i0
ad_connect  sys_rfifo_1/dac_rdata axi_ad9361/dac_data_q0
ad_connect  sys_rfifo_2/dac_rdata axi_ad9361/dac_data_i1
ad_connect  sys_rfifo_3/dac_rdata axi_ad9361/dac_data_q1
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins sys_rfifo_0/dac_rd]
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins sys_rfifo_1/dac_rd]
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins sys_rfifo_2/dac_rd]
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins sys_rfifo_3/dac_rd]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins sys_rfifo_0/dma_clk] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins sys_rfifo_1/dma_clk] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins sys_rfifo_2/dma_clk] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins sys_rfifo_3/dma_clk] [get_bd_pins util_clkdiv_0/clk_out]

regenerate_bd_layout