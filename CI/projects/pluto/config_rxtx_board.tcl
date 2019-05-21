global ref_design
global fpga_board

# Configure DMA
#set_property -dict [list CONFIG.DMA_DATA_WIDTH_SRC {32} CONFIG.DMA_DATA_WIDTH_DEST {256} CONFIG.SYNC_TRANSFER_START {false} CONFIG.DMA_AXI_PROTOCOL_DEST {0} CONFIG.DMA_TYPE_SRC {1} CONFIG.MAX_BYTES_PER_BURST {32768}] [get_bd_cells axi_ad9361_adc_dma]
#connect_bd_net [get_bd_pins axi_ad9361_adc_dma/s_axis_aclk] [get_bd_pins axi_ad9361/l_clk]
#connect_bd_net [get_bd_pins fir_decimator/m_axis_data_tdata] [get_bd_pins axi_ad9361_adc_dma/s_axis_data]
#connect_bd_net [get_bd_pins fir_decimator/m_axis_data_tvalid] [get_bd_pins axi_ad9361_adc_dma/s_axis_valid]

if {$ref_design eq "Rx" || $ref_design eq "Rx & Tx"} {
    # Disconnect the ADC PACK pins
    delete_bd_objs [get_bd_nets axi_ad9361_adc_data_i0]
    delete_bd_objs [get_bd_nets axi_ad9361_adc_data_q0]
    # Disconnect valid
    delete_bd_objs [get_bd_nets axi_ad9361_adc_valid_i0]
}

if {$ref_design eq "Tx" || $ref_design eq "Rx & Tx"} {
    # Disconnect the DAC UNPACK pins
    delete_bd_objs [get_bd_nets fir_interpolator_channel_0]
    delete_bd_objs [get_bd_nets fir_interpolator_channel_1]
    # Disconnect valid
    #delete_bd_objs [get_bd_nets axi_ad9361_dac_dma_fifo_rd_valid]
}