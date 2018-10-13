# Modem design modification from default reference design

#### Disconnect existing IPs

# Disconnect inputs into DAC FIFO
delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_0]
delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_1]
delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_2]
delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_3]

delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_valid_out_0]
delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_valid_out_1]
delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_valid_out_2]
delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_valid_out_3]

#### Add and connect new IPs

#### Modems RX data path
# Add new ADC DMA
create_bd_cell -type ip -vlnv analog.com:user:axi_dmac:1.0 axi_ad9361_adc_dma1
# Add interconnect for ADC DMA
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_hp3_interconnect
# Extend interconnect on PS
set_property -dict [list CONFIG.PCW_USE_S_AXI_HP3 {1}] [get_bd_cells sys_ps7]
# Connect IPs
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_hp3_interconnect/M00_AXI] [get_bd_intf_pins sys_ps7/S_AXI_HP3]
# Clocks
connect_bd_net [get_bd_pins axi_hp3_interconnect/ACLK] [get_bd_pins sys_ps7/FCLK_CLK0]
connect_bd_net [get_bd_pins axi_hp3_interconnect/S00_ACLK] [get_bd_pins sys_ps7/FCLK_CLK0]
connect_bd_net [get_bd_pins axi_hp3_interconnect/M00_ACLK] [get_bd_pins sys_ps7/FCLK_CLK0]
# Resets
connect_bd_net [get_bd_pins axi_hp3_interconnect/ARESETN] [get_bd_pins sys_rstgen/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_hp3_interconnect/S00_ARESETN] [get_bd_pins sys_rstgen/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_hp3_interconnect/M00_ARESETN] [get_bd_pins sys_rstgen/peripheral_aresetn]
# Data Interconnect To DMA
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_ad9361_adc_dma1/m_dest_axi] [get_bd_intf_pins axi_hp3_interconnect/S00_AXI]
# Clocks
connect_bd_net [get_bd_pins axi_ad9361_adc_dma1/s_axi_aclk] [get_bd_pins sys_ps7/FCLK_CLK0]
connect_bd_net [get_bd_pins axi_ad9361_adc_dma1/m_dest_axi_aclk] [get_bd_pins sys_ps7/FCLK_CLK0]
connect_bd_net [get_bd_pins axi_ad9361_adc_dma1/fifo_wr_clk] [get_bd_pins util_ad9361_divclk/clk_out]
# Resets
connect_bd_net [get_bd_pins axi_ad9361_adc_dma1/s_axi_aresetn] [get_bd_pins sys_rstgen/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ad9361_adc_dma1/m_dest_axi_aresetn] [get_bd_pins sys_rstgen/peripheral_aresetn]
# IRQ
delete_bd_objs [get_bd_nets ps_intr_11_1]
connect_bd_net [get_bd_pins sys_concat_intc/In11] [get_bd_pins axi_ad9361_adc_dma/irq]

#### Modems TX data path
# Add new DAC DMA
create_bd_cell -type ip -vlnv analog.com:user:axi_dmac:1.0 axi_ad9361_dac_dma1
# Add interconnect for DAC DMA
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_hp4_interconnect
# Extend interconnect on PS
#set_property -dict [list CONFIG.PCW_USE_S_AXI_HP4 {1}] [get_bd_cells sys_ps7]
# Connect IPs
#connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_hp4_interconnect/M00_AXI] [get_bd_intf_pins sys_ps7/S_AXI_HP3]
# Clocks
connect_bd_net [get_bd_pins axi_hp4_interconnect/ACLK] [get_bd_pins sys_ps7/FCLK_CLK0]
connect_bd_net [get_bd_pins axi_hp4_interconnect/S00_ACLK] [get_bd_pins sys_ps7/FCLK_CLK0]
connect_bd_net [get_bd_pins axi_hp4_interconnect/M00_ACLK] [get_bd_pins sys_ps7/FCLK_CLK0]
# Resets
connect_bd_net [get_bd_pins axi_hp4_interconnect/ARESETN] [get_bd_pins sys_rstgen/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_hp4_interconnect/S00_ARESETN] [get_bd_pins sys_rstgen/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_hp4_interconnect/M00_ARESETN] [get_bd_pins sys_rstgen/peripheral_aresetn]
# Data Interconnect To DMA
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_ad9361_dac_dma1/m_dest_axi] [get_bd_intf_pins axi_hp4_interconnect/S00_AXI]
# Clocks
connect_bd_net [get_bd_pins axi_ad9361_dac_dma1/s_axi_aclk] [get_bd_pins sys_ps7/FCLK_CLK0]
connect_bd_net [get_bd_pins axi_ad9361_dac_dma1/m_dest_axi_aclk] [get_bd_pins sys_ps7/FCLK_CLK0]
connect_bd_net [get_bd_pins axi_ad9361_dac_dma1/fifo_wr_clk] [get_bd_pins util_ad9361_divclk/clk_out]
# Resets
connect_bd_net [get_bd_pins axi_ad9361_dac_dma1/s_axi_aresetn] [get_bd_pins sys_rstgen/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_ad9361_dac_dma1/m_dest_axi_aresetn] [get_bd_pins sys_rstgen/peripheral_aresetn]
# IRQ
delete_bd_objs [get_bd_nets ps_intr_10_1]
connect_bd_net [get_bd_pins sys_concat_intc/In10] [get_bd_pins axi_ad9361_dac_dma/irq]



### Add mux
create_bd_cell -type ip -vlnv analog.com:user:util_mux:1.0 util_mux_0

# Connect mux INPUTS
connect_bd_net [get_bd_pins util_ad9361_dac_upack/dac_valid_out_0] [get_bd_pins util_mux_0/in0_0]
connect_bd_net [get_bd_pins util_ad9361_dac_upack/dac_valid_out_1] [get_bd_pins util_mux_0/in0_1]
connect_bd_net [get_bd_pins util_ad9361_dac_upack/dac_valid_out_2] [get_bd_pins util_mux_0/in0_2]
connect_bd_net [get_bd_pins util_ad9361_dac_upack/dac_valid_out_3] [get_bd_pins util_mux_0/in0_3]

connect_bd_net [get_bd_pins util_ad9361_dac_upack/dac_data_0] [get_bd_pins util_mux_0/in0_4]
connect_bd_net [get_bd_pins util_ad9361_dac_upack/dac_data_1] [get_bd_pins util_mux_0/in0_5]
connect_bd_net [get_bd_pins util_ad9361_dac_upack/dac_data_2] [get_bd_pins util_mux_0/in0_6]
connect_bd_net [get_bd_pins util_ad9361_dac_upack/dac_data_3] [get_bd_pins util_mux_0/in0_7]
# Remainin inputs come from GENERATED IP

# Connect mux OUTPUTS
connect_bd_net [get_bd_pins util_mux_0/out_0] [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_0]
connect_bd_net [get_bd_pins util_mux_0/out_1] [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_1]
connect_bd_net [get_bd_pins util_mux_0/out_2] [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_2]
connect_bd_net [get_bd_pins util_mux_0/out_3] [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_3]

connect_bd_net [get_bd_pins axi_ad9361_dac_fifo/din_data_0] [get_bd_pins util_mux_0/out_4]
connect_bd_net [get_bd_pins axi_ad9361_dac_fifo/din_data_1] [get_bd_pins util_mux_0/out_5]
connect_bd_net [get_bd_pins axi_ad9361_dac_fifo/din_data_2] [get_bd_pins util_mux_0/out_6]
connect_bd_net [get_bd_pins axi_ad9361_dac_fifo/din_data_3] [get_bd_pins util_mux_0/out_7]

















####
