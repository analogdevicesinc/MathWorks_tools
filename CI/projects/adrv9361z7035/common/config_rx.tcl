# Disconnect the ADC PACK pins
disconnect_bd_net /util_ad9361_adc_fifo_dout_valid_0 [get_bd_pins util_ad9361_adc_pack/adc_valid_0]
disconnect_bd_net /util_ad9361_adc_fifo_dout_valid_1 [get_bd_pins util_ad9361_adc_pack/adc_valid_1]
disconnect_bd_net /util_ad9361_adc_fifo_dout_valid_2 [get_bd_pins util_ad9361_adc_pack/adc_valid_2]
disconnect_bd_net /util_ad9361_adc_fifo_dout_valid_3 [get_bd_pins util_ad9361_adc_pack/adc_valid_3]

disconnect_bd_net /util_ad9361_adc_fifo_dout_data_0 [get_bd_pins util_ad9361_adc_pack/adc_data_0]
disconnect_bd_net /util_ad9361_adc_fifo_dout_data_1 [get_bd_pins util_ad9361_adc_pack/adc_data_1]
disconnect_bd_net /util_ad9361_adc_fifo_dout_data_2 [get_bd_pins util_ad9361_adc_pack/adc_data_2]
disconnect_bd_net /util_ad9361_adc_fifo_dout_data_3 [get_bd_pins util_ad9361_adc_pack/adc_data_3]

# Connect the ADC PACK valid signals together
connect_bd_net [get_bd_pins util_ad9361_adc_pack/adc_valid_0] [get_bd_pins util_ad9361_adc_pack/adc_valid_1]
connect_bd_net [get_bd_pins util_ad9361_adc_pack/adc_valid_0] [get_bd_pins util_ad9361_adc_pack/adc_valid_2]
connect_bd_net [get_bd_pins util_ad9361_adc_pack/adc_valid_0] [get_bd_pins util_ad9361_adc_pack/adc_valid_3]

global dma_config
# Configure DMA
if {[info exists dma_config]} {
    if {$dma_config eq "Packetized"} {
        set_property -dict [list CONFIG.DMA_DATA_WIDTH_SRC {64} CONFIG.DMA_DATA_WIDTH_DEST {256} CONFIG.SYNC_TRANSFER_START {false} CONFIG.DMA_AXI_PROTOCOL_DEST {0} CONFIG.DMA_TYPE_SRC {1} CONFIG.MAX_BYTES_PER_BURST {32768}] [get_bd_cells axi_ad9361_adc_dma]
        connect_bd_net [get_bd_pins axi_ad9361_adc_dma/s_axis_aclk] [get_bd_pins util_ad9361_divclk/clk_out]
        connect_bd_net [get_bd_pins util_ad9361_adc_pack/adc_data] [get_bd_pins axi_ad9361_adc_dma/s_axis_data]
        connect_bd_net [get_bd_pins axi_ad9361_adc_dma/s_axis_valid] [get_bd_pins util_ad9361_adc_pack/adc_valid]
    }
}
