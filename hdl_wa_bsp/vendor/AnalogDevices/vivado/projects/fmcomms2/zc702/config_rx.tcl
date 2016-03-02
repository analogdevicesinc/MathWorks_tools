# Disconnect the ADC PACK pins
disconnect_bd_net /axi_ad9361_clk [get_bd_pins util_adc_pack/clk]

disconnect_bd_net /axi_ad9361_adc_valid_i0 [get_bd_pins util_adc_pack/chan_valid_0]
disconnect_bd_net /axi_ad9361_adc_valid_q0 [get_bd_pins util_adc_pack/chan_valid_1]
disconnect_bd_net /axi_ad9361_adc_valid_i1 [get_bd_pins util_adc_pack/chan_valid_2]
disconnect_bd_net /axi_ad9361_adc_valid_q1 [get_bd_pins util_adc_pack/chan_valid_3]

disconnect_bd_net /axi_ad9361_adc_data_i0 [get_bd_pins util_adc_pack/chan_data_0]
disconnect_bd_net /axi_ad9361_adc_data_q0 [get_bd_pins util_adc_pack/chan_data_1]
disconnect_bd_net /axi_ad9361_adc_data_i1 [get_bd_pins util_adc_pack/chan_data_2]
disconnect_bd_net /axi_ad9361_adc_data_q1 [get_bd_pins util_adc_pack/chan_data_3]

# Disconnect the ADC DMA pins
disconnect_bd_net /axi_ad9361_clk [get_bd_pins axi_ad9361_adc_dma/fifo_wr_clk]
delete_bd_objs [get_bd_nets axi_ad9361_adc_dma_fifo_wr_overflow]

# Create the by 4 AD9361 clock divider 
create_bd_cell -type ip -vlnv analog.com:user:util_clkdiv:1.0 util_clkdiv_0
connect_bd_net -net [get_bd_nets axi_ad9361_clk] [get_bd_pins util_clkdiv_0/clk] [get_bd_pins axi_ad9361/l_clk]

# Connect the open clock nets
connect_bd_net [get_bd_pins util_clkdiv_0/clk_out] [get_bd_pins util_adc_pack/clk]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins axi_ad9361_adc_dma/fifo_wr_clk] [get_bd_pins util_clkdiv_0/clk_out]

# Connect the ADC PACK valid signals together
connect_bd_net [get_bd_pins util_adc_pack/chan_valid_0] [get_bd_pins util_adc_pack/chan_valid_1]
connect_bd_net [get_bd_pins util_adc_pack/chan_valid_0] [get_bd_pins util_adc_pack/chan_valid_2]
connect_bd_net [get_bd_pins util_adc_pack/chan_valid_0] [get_bd_pins util_adc_pack/chan_valid_3]

# Add an extra reset generator
set sys_rstgen1 [create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0]
set_property -dict [list CONFIG.C_EXT_RST_WIDTH {1}] $sys_rstgen1
connect_bd_net -net [get_bd_nets sys_ps7_FCLK_RESET0_N] [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins sys_ps7/FCLK_RESET0_N]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins util_clkdiv_0/clk_out]

# Add 2 extra AXI master ports to the interconnect
set_property -dict [list CONFIG.NUM_MI {10}] [get_bd_cells axi_cpu_interconnect]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins axi_cpu_interconnect/M08_ACLK] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins axi_cpu_interconnect/M09_ACLK] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins axi_cpu_interconnect/M08_ARESETN]
connect_bd_net [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins axi_cpu_interconnect/M09_ARESETN]

# Delete interrupt line 11
delete_bd_objs [get_bd_ports ps_intr_11]

# Delete the ILA block
delete_bd_objs [get_bd_nets sys_wfifo_0_dma_wr] [get_bd_nets sys_wfifo_1_dma_wr] [get_bd_nets sys_wfifo_2_dma_wr] [get_bd_nets sys_wfifo_3_dma_wr] [get_bd_nets sys_wfifo_0_dma_wdata] [get_bd_nets sys_wfifo_1_dma_wdata] [get_bd_nets sys_wfifo_2_dma_wdata] [get_bd_nets sys_wfifo_3_dma_wdata] [get_bd_cells ila_adc]

# Disconnect the ADC FIFO clocks
disconnect_bd_net /sys_cpu_clk [get_bd_pins sys_wfifo_0/dma_clk]
disconnect_bd_net /sys_cpu_clk [get_bd_pins sys_wfifo_1/dma_clk]
disconnect_bd_net /sys_cpu_clk [get_bd_pins sys_wfifo_2/dma_clk]
disconnect_bd_net /sys_cpu_clk [get_bd_pins sys_wfifo_3/dma_clk]

# Connect the ADC FIFO clocks to the AD9361 clock divider
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins sys_wfifo_0/dma_clk] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins sys_wfifo_1/dma_clk] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins sys_wfifo_2/dma_clk] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins sys_wfifo_3/dma_clk] [get_bd_pins util_clkdiv_0/clk_out]

regenerate_bd_layout


