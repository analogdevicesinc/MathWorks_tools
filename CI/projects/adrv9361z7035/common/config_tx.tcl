# Disconnect the DAC UNPACK pins
delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_valid_out_0]
delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_valid_out_1]
delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_valid_out_2]
delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_valid_out_3]

# Connect fifo valids together
connect_bd_net [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_1] [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_0]
connect_bd_net [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_2] [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_0]
connect_bd_net [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_3] [get_bd_pins axi_ad9361_dac_fifo/din_valid_in_0]

# Remove data lines where IP will go
delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_0]
delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_1]
delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_2]
delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_3]
