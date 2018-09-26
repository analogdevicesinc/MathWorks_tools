# Disconnect the DAC PACK pins
disconnect_bd_net /util_adrv9009_tx_upack_dac_data_0 [get_bd_pins axi_adrv9009_core/dac_data_i0]
disconnect_bd_net /util_adrv9009_tx_upack_dac_data_1 [get_bd_pins axi_adrv9009_core/dac_data_q0]
disconnect_bd_net /util_adrv9009_tx_upack_dac_data_2 [get_bd_pins axi_adrv9009_core/dac_data_i1]
disconnect_bd_net /util_adrv9009_tx_upack_dac_data_3 [get_bd_pins axi_adrv9009_core/dac_data_q1]

# Connect clock
connect_bd_net -net [get_bd_nets axi_adrv9009_tx_clkgen] [get_bd_pins axi_cpu_interconnect/M13_ACLK] [get_bd_pins axi_adrv9009_tx_clkgen/clk_0]
