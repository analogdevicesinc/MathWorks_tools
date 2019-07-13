global ref_design
global fpga_board

if {$ref_design eq "Rx" || $ref_design eq "Rx & Tx"} {
    # Disconnect the ADC PACK pins
    disconnect_bd_net /util_ad9361_adc_fifo_dout_valid_0 [get_bd_pins util_ad9361_adc_pack/adc_valid_0]
    disconnect_bd_net /util_ad9361_adc_fifo_dout_valid_1 [get_bd_pins util_ad9361_adc_pack/adc_valid_1]
    disconnect_bd_net /util_ad9361_adc_fifo_dout_valid_2 [get_bd_pins util_ad9361_adc_pack/adc_valid_2]
    disconnect_bd_net /util_ad9361_adc_fifo_dout_valid_3 [get_bd_pins util_ad9361_adc_pack/adc_valid_3]
    disconnect_bd_net /util_ad9361_adc_fifo_dout_valid_4 [get_bd_pins util_ad9361_adc_pack/adc_valid_4]
    disconnect_bd_net /util_ad9361_adc_fifo_dout_valid_5 [get_bd_pins util_ad9361_adc_pack/adc_valid_5]
    disconnect_bd_net /util_ad9361_adc_fifo_dout_valid_6 [get_bd_pins util_ad9361_adc_pack/adc_valid_6]
    disconnect_bd_net /util_ad9361_adc_fifo_dout_valid_7 [get_bd_pins util_ad9361_adc_pack/adc_valid_7]

    disconnect_bd_net /util_ad9361_adc_fifo_dout_data_0 [get_bd_pins util_ad9361_adc_pack/adc_data_0]
    disconnect_bd_net /util_ad9361_adc_fifo_dout_data_1 [get_bd_pins util_ad9361_adc_pack/adc_data_1]
    disconnect_bd_net /util_ad9361_adc_fifo_dout_data_2 [get_bd_pins util_ad9361_adc_pack/adc_data_2]
    disconnect_bd_net /util_ad9361_adc_fifo_dout_data_3 [get_bd_pins util_ad9361_adc_pack/adc_data_3]
    disconnect_bd_net /util_ad9361_adc_fifo_dout_data_4 [get_bd_pins util_ad9361_adc_pack/adc_data_4]
    disconnect_bd_net /util_ad9361_adc_fifo_dout_data_5 [get_bd_pins util_ad9361_adc_pack/adc_data_5]
    disconnect_bd_net /util_ad9361_adc_fifo_dout_data_6 [get_bd_pins util_ad9361_adc_pack/adc_data_6]
    disconnect_bd_net /util_ad9361_adc_fifo_dout_data_7 [get_bd_pins util_ad9361_adc_pack/adc_data_7]

    # Connect the ADC PACK valid signals together
    connect_bd_net [get_bd_pins util_ad9361_adc_pack/adc_valid_0] [get_bd_pins util_ad9361_adc_pack/adc_valid_1]
    connect_bd_net [get_bd_pins util_ad9361_adc_pack/adc_valid_0] [get_bd_pins util_ad9361_adc_pack/adc_valid_2]
    connect_bd_net [get_bd_pins util_ad9361_adc_pack/adc_valid_0] [get_bd_pins util_ad9361_adc_pack/adc_valid_3]
    connect_bd_net [get_bd_pins util_ad9361_adc_pack/adc_valid_0] [get_bd_pins util_ad9361_adc_pack/adc_valid_4]
    connect_bd_net [get_bd_pins util_ad9361_adc_pack/adc_valid_0] [get_bd_pins util_ad9361_adc_pack/adc_valid_5]
    connect_bd_net [get_bd_pins util_ad9361_adc_pack/adc_valid_0] [get_bd_pins util_ad9361_adc_pack/adc_valid_6]
    connect_bd_net [get_bd_pins util_ad9361_adc_pack/adc_valid_0] [get_bd_pins util_ad9361_adc_pack/adc_valid_7]
}

if {$ref_design eq "Tx" || $ref_design eq "Rx & Tx"} {
    # Disconnect the DAC UNPACK pins
    delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_valid_out_0]
    delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_valid_out_1]
    delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_valid_out_2]
    delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_valid_out_3]
    delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_valid_out_4]
    delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_valid_out_5]
    delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_valid_out_6]
    delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_valid_out_7]

    # Connect fifo valids together
    connect_bd_net [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_1] [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_0]
    connect_bd_net [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_2] [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_0]
    connect_bd_net [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_3] [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_0]
    connect_bd_net [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_4] [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_0]
    connect_bd_net [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_5] [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_0]
    connect_bd_net [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_6] [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_0]
    connect_bd_net [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_7] [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_0]

    # Remove data lines where IP will go
    delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_0]
    delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_1]
    delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_2]
    delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_3]
    delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_4]
    delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_5]
    delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_6]
    delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_7]
}
