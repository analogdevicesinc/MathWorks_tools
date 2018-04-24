# Disconnect the ADC FIFO pins
disconnect_bd_net /sys_cpu_clk [get_bd_pins util_ad9361_adc_fifo/dout_clk]
disconnect_bd_net /sys_cpu_resetn [get_bd_pins util_ad9361_adc_fifo/dout_rstn]

# Disconnect the ADC PACK pins
disconnect_bd_net /sys_cpu_clk [get_bd_pins util_ad9361_adc_pack/adc_clk]
delete_bd_objs [get_bd_nets sys_cpu_reset]

disconnect_bd_net /util_ad9361_adc_fifo_dout_valid_0 [get_bd_pins util_ad9361_adc_pack/adc_valid_0]
disconnect_bd_net /util_ad9361_adc_fifo_dout_valid_1 [get_bd_pins util_ad9361_adc_pack/adc_valid_1]
disconnect_bd_net /util_ad9361_adc_fifo_dout_valid_2 [get_bd_pins util_ad9361_adc_pack/adc_valid_2]
disconnect_bd_net /util_ad9361_adc_fifo_dout_valid_3 [get_bd_pins util_ad9361_adc_pack/adc_valid_3]

disconnect_bd_net /util_ad9361_adc_fifo_dout_data_0 [get_bd_pins util_ad9361_adc_pack/adc_data_0]
disconnect_bd_net /util_ad9361_adc_fifo_dout_data_1 [get_bd_pins util_ad9361_adc_pack/adc_data_1]
disconnect_bd_net /util_ad9361_adc_fifo_dout_data_2 [get_bd_pins util_ad9361_adc_pack/adc_data_2]
disconnect_bd_net /util_ad9361_adc_fifo_dout_data_3 [get_bd_pins util_ad9361_adc_pack/adc_data_3]

# Disconnect the ADC DMA pins
disconnect_bd_net /sys_cpu_clk [get_bd_pins axi_ad9361_adc_dma/fifo_wr_clk]
delete_bd_objs [get_bd_nets axi_ad9361_adc_dma_fifo_wr_overflow]

# Connect the open clock nets
connect_bd_net [get_bd_pins util_clkdiv_0/clk_out] [get_bd_pins util_ad9361_adc_pack/adc_clk]
connect_bd_net [get_bd_pins util_clkdiv_0/clk_out] [get_bd_pins util_ad9361_adc_fifo/dout_clk]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins axi_ad9361_adc_dma/fifo_wr_clk] [get_bd_pins util_clkdiv_0/clk_out]

# Connect the open reset nets
connect_bd_net [get_bd_pins util_ad9361_adc_pack/adc_rst] [get_bd_pins proc_sys_reset_0/peripheral_reset]
connect_bd_net -net [get_bd_nets proc_sys_reset_0_peripheral_aresetn] [get_bd_pins util_ad9361_adc_fifo/dout_rstn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]

# Connect the ADC PACK valid signals together
connect_bd_net [get_bd_pins util_ad9361_adc_pack/adc_valid_0] [get_bd_pins util_ad9361_adc_pack/adc_valid_1]
connect_bd_net [get_bd_pins util_ad9361_adc_pack/adc_valid_0] [get_bd_pins util_ad9361_adc_pack/adc_valid_2]
connect_bd_net [get_bd_pins util_ad9361_adc_pack/adc_valid_0] [get_bd_pins util_ad9361_adc_pack/adc_valid_3]
