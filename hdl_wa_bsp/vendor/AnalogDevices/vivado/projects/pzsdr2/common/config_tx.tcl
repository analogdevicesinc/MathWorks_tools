# Disconnect the DAC UNPACK pins
delete_bd_objs [get_bd_nets axi_ad9361_dac_valid_i0]
delete_bd_objs [get_bd_nets axi_ad9361_dac_valid_q0]
delete_bd_objs [get_bd_nets axi_ad9361_dac_valid_i1]
delete_bd_objs [get_bd_nets axi_ad9361_dac_valid_q1]

delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_0]
delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_1]
delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_2]
delete_bd_objs [get_bd_nets util_ad9361_dac_upack_dac_data_3]

# Connect the DAC UNPACK valid signals together
connect_bd_net [get_bd_pins util_ad9361_dac_upack/unpack_valid_0] [get_bd_pins util_ad9361_dac_upack/unpack_valid_1]
connect_bd_net [get_bd_pins util_ad9361_dac_upack/unpack_valid_0] [get_bd_pins util_ad9361_dac_upack/unpack_valid_2]
connect_bd_net [get_bd_pins util_ad9361_dac_upack/unpack_valid_0] [get_bd_pins util_ad9361_dac_upack/unpack_valid_3]
