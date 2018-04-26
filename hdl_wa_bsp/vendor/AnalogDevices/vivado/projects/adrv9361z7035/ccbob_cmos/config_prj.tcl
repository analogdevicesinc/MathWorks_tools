# Add 1 extra AXI master ports to the interconnect
set_property -dict [list CONFIG.NUM_MI {7}] [get_bd_cells axi_cpu_interconnect]
connect_bd_net -net [get_bd_nets util_ad9361_divclk_clk_out] [get_bd_pins axi_cpu_interconnect/M06_ACLK] [get_bd_pins util_ad9361_divclk/clk_out]
connect_bd_net [get_bd_pins util_ad9361_divclk_reset/interconnect_aresetn] [get_bd_pins axi_cpu_interconnect/M06_ARESETN]
