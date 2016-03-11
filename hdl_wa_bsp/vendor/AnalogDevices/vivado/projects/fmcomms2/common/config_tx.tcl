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

# Connect the open clock nets
connect_bd_net [get_bd_pins util_dac_unpack/clk] [get_bd_pins util_clkdiv_0/clk_out]
connect_bd_net -net [get_bd_nets util_clkdiv_0_clk_out] [get_bd_pins axi_ad9361_dac_dma/fifo_rd_clk] [get_bd_pins util_clkdiv_0/clk_out]

# Connect the DAC UNPACK valid signals together
connect_bd_net [get_bd_pins util_dac_unpack/dac_valid_00] [get_bd_pins util_dac_unpack/dac_valid_01]
connect_bd_net [get_bd_pins util_dac_unpack/dac_valid_00] [get_bd_pins util_dac_unpack/dac_valid_02]
connect_bd_net [get_bd_pins util_dac_unpack/dac_valid_00] [get_bd_pins util_dac_unpack/dac_valid_03]

# Create the Tx clock transition FIFOs
p_sys_rfifo [current_bd_instance .] sys_rfifo_0 16 16
p_sys_rfifo [current_bd_instance .] sys_rfifo_1 16 16
p_sys_rfifo [current_bd_instance .] sys_rfifo_2 16 16
p_sys_rfifo [current_bd_instance .] sys_rfifo_3 16 16

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