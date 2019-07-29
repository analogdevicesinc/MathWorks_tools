set ad_hdl_dir    	[pwd]
set proj_dir		$ad_hdl_dir/projects/adrv9361z7035/ccfmc_lvds_agc

source $proj_dir/config_prj.tcl
source $ad_hdl_dir/projects/adrv9361z7035/common/config_rx.tcl

# Configure DMA
set_property -dict [list CONFIG.DMA_DATA_WIDTH_SRC {64} CONFIG.DMA_DATA_WIDTH_DEST {256} CONFIG.SYNC_TRANSFER_START {false} CONFIG.DMA_AXI_PROTOCOL_DEST {0} CONFIG.DMA_TYPE_SRC {1} CONFIG.MAX_BYTES_PER_BURST {32768}] [get_bd_cells axi_ad9361_adc_dma]
connect_bd_net [get_bd_pins axi_ad9361_adc_dma/s_axis_aclk] [get_bd_pins util_ad9361_divclk/clk_out]
connect_bd_net [get_bd_pins util_ad9361_adc_pack/adc_data] [get_bd_pins axi_ad9361_adc_dma/s_axis_data]
connect_bd_net [get_bd_pins axi_ad9361_adc_dma/s_axis_valid] [get_bd_pins util_ad9361_adc_pack/adc_valid]

regenerate_bd_layout