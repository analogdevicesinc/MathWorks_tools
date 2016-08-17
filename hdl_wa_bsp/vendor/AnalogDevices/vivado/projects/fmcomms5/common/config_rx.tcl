# Disconnect the ADC PACK pins
disconnect_bd_net /axi_ad9361_0_clk [get_bd_pins util_adc_pack_0/clk]

disconnect_bd_net /axi_ad9361_0_adc_valid_i0 [get_bd_pins util_adc_pack_0/chan_valid_0]
disconnect_bd_net /axi_ad9361_0_adc_valid_q0 [get_bd_pins util_adc_pack_0/chan_valid_1]
disconnect_bd_net /axi_ad9361_0_adc_valid_i1 [get_bd_pins util_adc_pack_0/chan_valid_2]
disconnect_bd_net /axi_ad9361_0_adc_valid_q1 [get_bd_pins util_adc_pack_0/chan_valid_3]

disconnect_bd_net /axi_ad9361_1_adc_valid_i0 [get_bd_pins util_adc_pack_0/chan_valid_4]
disconnect_bd_net /axi_ad9361_1_adc_valid_q0 [get_bd_pins util_adc_pack_0/chan_valid_5]
disconnect_bd_net /axi_ad9361_1_adc_valid_i1 [get_bd_pins util_adc_pack_0/chan_valid_6]
disconnect_bd_net /axi_ad9361_1_adc_valid_q1 [get_bd_pins util_adc_pack_0/chan_valid_7]

disconnect_bd_net /axi_ad9361_0_adc_data_i0 [get_bd_pins util_adc_pack_0/chan_data_0]
disconnect_bd_net /axi_ad9361_0_adc_data_q0 [get_bd_pins util_adc_pack_0/chan_data_1]
disconnect_bd_net /axi_ad9361_0_adc_data_i1 [get_bd_pins util_adc_pack_0/chan_data_2]
disconnect_bd_net /axi_ad9361_0_adc_data_q1 [get_bd_pins util_adc_pack_0/chan_data_3]

disconnect_bd_net /axi_ad9361_1_adc_data_i0 [get_bd_pins util_adc_pack_0/chan_data_4]
disconnect_bd_net /axi_ad9361_1_adc_data_q0 [get_bd_pins util_adc_pack_0/chan_data_5]
disconnect_bd_net /axi_ad9361_1_adc_data_i1 [get_bd_pins util_adc_pack_0/chan_data_6]
disconnect_bd_net /axi_ad9361_1_adc_data_q1 [get_bd_pins util_adc_pack_0/chan_data_7]

# Disconnect the ADC DMA pins
disconnect_bd_net /axi_ad9361_0_clk [get_bd_pins axi_ad9361_adc_dma/fifo_wr_clk]
delete_bd_objs [get_bd_nets axi_ad9361_adc_dma_fifo_wr_overflow]

# Connect the open clock nets
connect_bd_net [get_bd_pins util_clkdiv_0/clk_out] [get_bd_pins util_adc_pack_0/clk]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins axi_ad9361_adc_dma/fifo_wr_clk] [get_bd_pins util_clkdiv_0/clk_out]

# Connect the ADC PACK valid signals together
connect_bd_net [get_bd_pins util_adc_pack_0/chan_valid_0] [get_bd_pins util_adc_pack_0/chan_valid_1]
connect_bd_net [get_bd_pins util_adc_pack_0/chan_valid_0] [get_bd_pins util_adc_pack_0/chan_valid_2]
connect_bd_net [get_bd_pins util_adc_pack_0/chan_valid_0] [get_bd_pins util_adc_pack_0/chan_valid_3]
connect_bd_net [get_bd_pins util_adc_pack_0/chan_valid_0] [get_bd_pins util_adc_pack_0/chan_valid_4]
connect_bd_net [get_bd_pins util_adc_pack_0/chan_valid_0] [get_bd_pins util_adc_pack_0/chan_valid_5]
connect_bd_net [get_bd_pins util_adc_pack_0/chan_valid_0] [get_bd_pins util_adc_pack_0/chan_valid_6]
connect_bd_net [get_bd_pins util_adc_pack_0/chan_valid_0] [get_bd_pins util_adc_pack_0/chan_valid_7]

# Create the ADC FIFOs
p_sys_wfifo [current_bd_instance .] sys_wfifo_0 16 16
p_sys_wfifo [current_bd_instance .] sys_wfifo_1 16 16
p_sys_wfifo [current_bd_instance .] sys_wfifo_2 16 16
p_sys_wfifo [current_bd_instance .] sys_wfifo_3 16 16

p_sys_wfifo [current_bd_instance .] sys_wfifo_4 16 16
p_sys_wfifo [current_bd_instance .] sys_wfifo_5 16 16
p_sys_wfifo [current_bd_instance .] sys_wfifo_6 16 16
p_sys_wfifo [current_bd_instance .] sys_wfifo_7 16 16

# Connect the ADC FIFOs data, clock and valid signals
ad_connect  sys_wfifo_0/adc_wr axi_ad9361_0/adc_valid_i0
ad_connect  sys_wfifo_1/adc_wr axi_ad9361_0/adc_valid_q0
ad_connect  sys_wfifo_2/adc_wr axi_ad9361_0/adc_valid_i1
ad_connect  sys_wfifo_3/adc_wr axi_ad9361_0/adc_valid_q1
ad_connect  sys_wfifo_0/adc_wdata axi_ad9361_0/adc_data_i0
ad_connect  sys_wfifo_1/adc_wdata axi_ad9361_0/adc_data_q0
ad_connect  sys_wfifo_2/adc_wdata axi_ad9361_0/adc_data_i1
ad_connect  sys_wfifo_3/adc_wdata axi_ad9361_0/adc_data_q1

ad_connect  axi_ad9361_0_clk sys_wfifo_0/adc_clk
ad_connect  axi_ad9361_0_clk sys_wfifo_1/adc_clk
ad_connect  axi_ad9361_0_clk sys_wfifo_2/adc_clk
ad_connect  axi_ad9361_0_clk sys_wfifo_3/adc_clk
ad_connect  axi_ad9361_0_clk sys_wfifo_4/adc_clk
ad_connect  axi_ad9361_0_clk sys_wfifo_5/adc_clk
ad_connect  axi_ad9361_0_clk sys_wfifo_6/adc_clk
ad_connect  axi_ad9361_0_clk sys_wfifo_7/adc_clk

ad_connect  sys_wfifo_4/adc_wr axi_ad9361_1/adc_valid_i0
ad_connect  sys_wfifo_5/adc_wr axi_ad9361_1/adc_valid_q0
ad_connect  sys_wfifo_6/adc_wr axi_ad9361_1/adc_valid_i1
ad_connect  sys_wfifo_7/adc_wr axi_ad9361_1/adc_valid_q1
ad_connect  sys_wfifo_4/adc_wdata axi_ad9361_1/adc_data_i0
ad_connect  sys_wfifo_5/adc_wdata axi_ad9361_1/adc_data_q0
ad_connect  sys_wfifo_6/adc_wdata axi_ad9361_1/adc_data_i1
ad_connect  sys_wfifo_7/adc_wdata axi_ad9361_1/adc_data_q1

# Connect the ADC FIFO clocks to the AD9361 clock divider
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins sys_wfifo_0/dma_clk] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins sys_wfifo_1/dma_clk] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins sys_wfifo_2/dma_clk] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins sys_wfifo_3/dma_clk] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins sys_wfifo_4/dma_clk] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins sys_wfifo_5/dma_clk] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins sys_wfifo_6/dma_clk] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins sys_wfifo_7/dma_clk] [get_bd_pins util_clkdiv_0/clk_out]