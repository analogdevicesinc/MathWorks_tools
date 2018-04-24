# Add 1 extra AXI master ports to the interconnect
set_property -dict [list CONFIG.NUM_MI {9}] [get_bd_cells axi_cpu_interconnect]
connect_bd_net -net [get_bd_nets clkdiv_clk_out] [get_bd_pins axi_cpu_interconnect/M08_ACLK] [get_bd_pins clkdiv/clk_out]
connect_bd_net [get_bd_pins clkdiv_reset/interconnect_aresetn] [get_bd_pins axi_cpu_interconnect/M08_ARESETN]