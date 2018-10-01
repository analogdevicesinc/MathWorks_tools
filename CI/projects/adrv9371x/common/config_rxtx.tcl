
global ref_design

if {$ref_design eq "Rx" || $ref_design eq "Rx & Tx"} {
# Disconnect the ADC PACK pins
disconnect_bd_net /axi_ad9371_core_adc_valid_i0 [get_bd_pins util_ad9371_rx_cpack/adc_valid_0]
disconnect_bd_net /axi_ad9371_core_adc_valid_q0 [get_bd_pins util_ad9371_rx_cpack/adc_valid_1]
disconnect_bd_net /axi_ad9371_core_adc_valid_i1 [get_bd_pins util_ad9371_rx_cpack/adc_valid_2]
disconnect_bd_net /axi_ad9371_core_adc_valid_q1 [get_bd_pins util_ad9371_rx_cpack/adc_valid_3]
disconnect_bd_net /axi_ad9371_core_adc_data_i0 [get_bd_pins util_ad9371_rx_cpack/adc_data_0]
disconnect_bd_net /axi_ad9371_core_adc_data_q0 [get_bd_pins util_ad9371_rx_cpack/adc_data_1]
disconnect_bd_net /axi_ad9371_core_adc_data_i1 [get_bd_pins util_ad9371_rx_cpack/adc_data_2]
disconnect_bd_net /axi_ad9371_core_adc_data_q1 [get_bd_pins util_ad9371_rx_cpack/adc_data_3]

# Connect the ADC PACK valid signals together
connect_bd_net [get_bd_pins util_ad9371_rx_cpack/adc_valid_0] [get_bd_pins util_ad9371_rx_cpack/adc_valid_1]
connect_bd_net [get_bd_pins util_ad9371_rx_cpack/adc_valid_0] [get_bd_pins util_ad9371_rx_cpack/adc_valid_2]
connect_bd_net [get_bd_pins util_ad9371_rx_cpack/adc_valid_0] [get_bd_pins util_ad9371_rx_cpack/adc_valid_3]

}
# Connect clock
if {$ref_design eq "Rx" || $ref_design eq "Rx & Tx"} {
connect_bd_net -net [get_bd_nets axi_ad9371_rx_clkgen] [get_bd_pins axi_cpu_interconnect/M13_ACLK] [get_bd_pins axi_ad9371_rx_clkgen/clk_0]
}
if {$ref_design eq "Tx"} {
connect_bd_net -net [get_bd_nets axi_ad9371_tx_clkgen] [get_bd_pins axi_cpu_interconnect/M13_ACLK] [get_bd_pins axi_ad9371_tx_clkgen/clk_0]
}

########################
if {$ref_design eq "Tx" || $ref_design eq "Rx & Tx"} {
# Disconnect the DAC PACK pins
disconnect_bd_net /util_ad9371_tx_upack_dac_data_0 [get_bd_pins axi_ad9371_core/dac_data_i0]
disconnect_bd_net /util_ad9371_tx_upack_dac_data_1 [get_bd_pins axi_ad9371_core/dac_data_q0]
disconnect_bd_net /util_ad9371_tx_upack_dac_data_2 [get_bd_pins axi_ad9371_core/dac_data_i1]
disconnect_bd_net /util_ad9371_tx_upack_dac_data_3 [get_bd_pins axi_ad9371_core/dac_data_q1]
}
