global ref_design
global fpga_board
global dma

# Add System Reset IP
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0
endgroup
connect_bd_net [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins sys_rstgen/peripheral_aresetn]
connect_bd_net [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins axi_ad9361/l_clk]

# Add 1 extra AXI master ports to the interconnect
set_property -dict [list CONFIG.NUM_MI {5}] [get_bd_cells axi_cpu_interconnect]
connect_bd_net [get_bd_pins axi_cpu_interconnect/M04_ACLK] [get_bd_pins axi_ad9361/l_clk]
connect_bd_net [get_bd_pins axi_cpu_interconnect/M04_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]

# Remove filters
delete_bd_objs [get_bd_cells fir_decimator]
delete_bd_objs [get_bd_cells fir_interpolator]

# Configure DMA
if {$dma eq "Packetized"} {
    set_property -dict [list CONFIG.DMA_DATA_WIDTH_SRC {32} CONFIG.DMA_DATA_WIDTH_DEST {256} CONFIG.SYNC_TRANSFER_START {false} CONFIG.DMA_AXI_PROTOCOL_DEST {0} CONFIG.DMA_TYPE_SRC {1} CONFIG.MAX_BYTES_PER_BURST {32768}] [get_bd_cells axi_ad9361_adc_dma]
    connect_bd_net [get_bd_pins axi_ad9361_adc_dma/s_axis_aclk] [get_bd_pins axi_ad9361/l_clk]
}

# Insert pack cores
startgroup
create_bd_cell -type ip -vlnv analog.com:user:util_cpack:1.0 util_cpack_0
endgroup
set_property -dict [list CONFIG.CHANNEL_DATA_WIDTH {16} CONFIG.NUM_OF_CHANNELS {2}] [get_bd_cells util_cpack_0]

# Clocks and resets
connect_bd_net [get_bd_pins util_cpack_0/adc_clk] [get_bd_pins axi_ad9361/l_clk]
connect_bd_net [get_bd_pins util_cpack_0/adc_rst] [get_bd_pins proc_sys_reset_0/peripheral_reset]

# Connect enables
connect_bd_net [get_bd_pins axi_ad9361/adc_enable_i0] [get_bd_pins util_cpack_0/adc_enable_0]
connect_bd_net [get_bd_pins axi_ad9361/adc_enable_q0] [get_bd_pins util_cpack_0/adc_enable_1]
# Connect valids together
connect_bd_net [get_bd_pins util_cpack_0/adc_valid_1] [get_bd_pins util_cpack_0/adc_valid_0]


############ DMA MODE
if {$dma eq "Packetized"} {
    # Packetized DMA
    connect_bd_net [get_bd_pins util_cpack_0/adc_data] [get_bd_pins axi_ad9361_adc_dma/s_axis_data]
    connect_bd_net [get_bd_pins util_cpack_0/adc_valid] [get_bd_pins axi_ad9361_adc_dma/s_axis_valid]
} else {
    # FIFO DMA
    connect_bd_net [get_bd_pins util_cpack_0/adc_data] [get_bd_pins axi_ad9361_adc_dma/fifo_wr_din]
    connect_bd_net [get_bd_pins util_cpack_0/adc_valid] [get_bd_pins axi_ad9361_adc_dma/fifo_wr_en]
}

###### UnPack
startgroup
create_bd_cell -type ip -vlnv analog.com:user:util_upack:1.0 util_upack_0
endgroup
set_property -dict [list CONFIG.CHANNEL_DATA_WIDTH {16} CONFIG.NUM_OF_CHANNELS {2}] [get_bd_cells util_upack_0]
# Connect data
connect_bd_net [get_bd_pins util_upack_0/dac_data_0] [get_bd_pins axi_ad9361/dac_data_i0]
connect_bd_net [get_bd_pins util_upack_0/dac_data_1] [get_bd_pins axi_ad9361/dac_data_q0]
connect_bd_net [get_bd_pins axi_ad9361_dac_dma/fifo_rd_dout] [get_bd_pins util_upack_0/dac_data]
# Connect Clock
connect_bd_net [get_bd_pins util_upack_0/dac_clk] [get_bd_pins axi_ad9361/l_clk]
# Valid from pack to DMA
connect_bd_net [get_bd_pins util_upack_0/dac_valid] [get_bd_pins axi_ad9361_dac_dma/fifo_rd_en]

# 
#connect_bd_net [get_bd_pins axi_ad9361_dac_dma/fifo_rd_valid] [get_bd_pins util_upack_0/dac_valid_0]
#connect_bd_net [get_bd_pins util_upack_0/dac_valid_1] [get_bd_pins axi_ad9361_dac_dma/fifo_rd_valid]

# Input valids
connect_bd_net [get_bd_pins axi_ad9361_dac_dma/fifo_rd_valid] [get_bd_pins util_upack_0/dac_enable_0]
connect_bd_net [get_bd_pins util_upack_0/dac_valid_0] [get_bd_pins axi_ad9361_dac_dma/fifo_rd_valid]
connect_bd_net [get_bd_pins util_upack_0/dac_valid_1] [get_bd_pins axi_ad9361_dac_dma/fifo_rd_valid]
connect_bd_net [get_bd_pins util_upack_0/dac_enable_1] [get_bd_pins axi_ad9361_dac_dma/fifo_rd_valid]


