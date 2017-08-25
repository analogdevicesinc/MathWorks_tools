# Delete the pack & unpack
delete_bd_objs [get_bd_nets util_ad9361_adc_fifo_dout_enable_0] [get_bd_nets util_ad9361_adc_fifo_dout_valid_0] [get_bd_nets util_ad9361_adc_fifo_dout_enable_1] [get_bd_nets util_ad9361_adc_fifo_dout_data_1] [get_bd_nets util_ad9361_adc_fifo_dout_valid_2] [get_bd_nets util_ad9361_adc_fifo_dout_enable_3] [get_bd_nets util_ad9361_adc_fifo_dout_data_3] [get_bd_nets util_ad9361_adc_pack_adc_valid] [get_bd_nets util_ad9361_adc_pack_adc_sync] [get_bd_nets util_ad9361_adc_pack_adc_data] [get_bd_nets clkdiv_reset_peripheral_reset] [get_bd_nets util_ad9361_adc_fifo_dout_data_0] [get_bd_nets util_ad9361_adc_fifo_dout_valid_1] [get_bd_nets util_ad9361_adc_fifo_dout_enable_2] [get_bd_nets util_ad9361_adc_fifo_dout_data_2] [get_bd_nets util_ad9361_adc_fifo_dout_valid_3] [get_bd_cells util_ad9361_adc_pack]
delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_0] [get_bd_nets dac_fifo_din_enable_1] [get_bd_nets util_ad9361_dac_upack_dac_data_1] [get_bd_nets dac_fifo_din_enable_2] [get_bd_nets util_ad9361_dac_upack_dac_data_2] [get_bd_nets dac_fifo_din_enable_3] [get_bd_nets util_ad9361_dac_upack_dac_data_3] [get_bd_nets util_ad9361_dac_upack_dac_valid] [get_bd_nets dac_fifo_din_enable_0] [get_bd_nets dac_fifo_din_valid_0] [get_bd_nets dac_fifo_din_valid_1] [get_bd_nets dac_fifo_din_valid_2] [get_bd_nets dac_fifo_din_valid_3] [get_bd_nets axi_ad9361_dac_dma_fifo_rd_dout] [get_bd_cells util_ad9361_dac_upack]

# Add 1 extra AXI master ports to the interconnect
set_property -dict [list CONFIG.NUM_MI {6}] [get_bd_cells axi_cpu_interconnect]
connect_bd_net -net [get_bd_nets clkdiv_clk_out] [get_bd_pins axi_cpu_interconnect/M05_ACLK] [get_bd_pins clkdiv/clk_out]
connect_bd_net [get_bd_pins clkdiv_reset/interconnect_aresetn] [get_bd_pins axi_cpu_interconnect/M05_ARESETN]

# Add an ILA for debugging
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.1 ila_0
set_property -dict [list CONFIG.C_PROBE15_TYPE {1} CONFIG.C_PROBE14_TYPE {1} CONFIG.C_PROBE13_TYPE {1} CONFIG.C_PROBE12_TYPE {1} CONFIG.C_PROBE11_TYPE {1} CONFIG.C_PROBE10_TYPE {1} CONFIG.C_PROBE9_TYPE {1} CONFIG.C_PROBE8_TYPE {1} CONFIG.C_PROBE15_WIDTH {32} CONFIG.C_PROBE14_WIDTH {32} CONFIG.C_PROBE13_WIDTH {32} CONFIG.C_PROBE12_WIDTH {32} CONFIG.C_PROBE11_WIDTH {16} CONFIG.C_PROBE10_WIDTH {16} CONFIG.C_PROBE9_WIDTH {16} CONFIG.C_PROBE8_WIDTH {16} CONFIG.C_DATA_DEPTH {32768} CONFIG.C_NUM_OF_PROBES {16} CONFIG.C_EN_STRG_QUAL {1} CONFIG.C_ADV_TRIGGER {true} CONFIG.C_MONITOR_TYPE {Native} CONFIG.C_PROBE15_MU_CNT {2} CONFIG.C_PROBE14_MU_CNT {2} CONFIG.C_PROBE13_MU_CNT {2} CONFIG.C_PROBE12_MU_CNT {2} CONFIG.C_PROBE11_MU_CNT {2} CONFIG.C_PROBE10_MU_CNT {2} CONFIG.C_PROBE9_MU_CNT {2} CONFIG.C_PROBE8_MU_CNT {2} CONFIG.C_PROBE7_MU_CNT {2} CONFIG.C_PROBE6_MU_CNT {2} CONFIG.C_PROBE5_MU_CNT {2} CONFIG.C_PROBE4_MU_CNT {2} CONFIG.C_PROBE3_MU_CNT {2} CONFIG.C_PROBE2_MU_CNT {2} CONFIG.C_PROBE1_MU_CNT {2} CONFIG.C_PROBE0_MU_CNT {2} CONFIG.ALL_PROBE_SAME_MU_CNT {2} CONFIG.C_ENABLE_ILA_AXI_MON {false}] [get_bd_cells ila_0]
connect_bd_net [get_bd_pins ila_0/clk] [get_bd_pins clkdiv/clk_out]
endgroup

# Add an interface to ILA to pass validate design
create_bd_cell -type ip -vlnv analog.com:user:util_if:1.0 util_if_0
connect_bd_net [get_bd_pins util_if_0/port00o] [get_bd_pins ila_0/probe0]
connect_bd_net [get_bd_pins util_if_0/port01o] [get_bd_pins ila_0/probe1]
connect_bd_net [get_bd_pins util_if_0/port02o] [get_bd_pins ila_0/probe2]
connect_bd_net [get_bd_pins util_if_0/port03o] [get_bd_pins ila_0/probe3]
connect_bd_net [get_bd_pins util_if_0/port04o] [get_bd_pins ila_0/probe4]
connect_bd_net [get_bd_pins util_if_0/port05o] [get_bd_pins ila_0/probe5]
connect_bd_net [get_bd_pins util_if_0/port06o] [get_bd_pins ila_0/probe6]
connect_bd_net [get_bd_pins util_if_0/port07o] [get_bd_pins ila_0/probe7]
connect_bd_net [get_bd_pins util_if_0/port08o] [get_bd_pins ila_0/probe8]
connect_bd_net [get_bd_pins util_if_0/port09o] [get_bd_pins ila_0/probe9]
connect_bd_net [get_bd_pins util_if_0/port10o] [get_bd_pins ila_0/probe10]
connect_bd_net [get_bd_pins util_if_0/port11o] [get_bd_pins ila_0/probe11]
connect_bd_net [get_bd_pins util_if_0/port12o] [get_bd_pins ila_0/probe12]
connect_bd_net [get_bd_pins util_if_0/port13o] [get_bd_pins ila_0/probe13]
connect_bd_net [get_bd_pins util_if_0/port14o] [get_bd_pins ila_0/probe14]
connect_bd_net [get_bd_pins util_if_0/port15o] [get_bd_pins ila_0/probe15]
