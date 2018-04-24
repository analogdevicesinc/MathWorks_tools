open_project vivado_prj.xpr
update_ip_catalog -delete_ip {./ipcore/Detector_ip_v1_0/component.xml} -repo_path {./ipcore} -quiet
update_ip_catalog -add_ip {./ipcore/Detector_ip_v1_0.zip} -repo_path {./ipcore}
update_ip_catalog
set HDLCODERIPVLNV [get_property VLNV [get_ipdefs -filter {NAME==Detector_ip && VERSION==1.0}]]
set HDLCODERIPINST Detector_ip_0
set BDFILEPATH [get_files -quiet system.bd]
open_bd_design $BDFILEPATH
create_bd_cell -type ip -vlnv $HDLCODERIPVLNV $HDLCODERIPINST
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins clkdiv/clk_out]] [get_bd_pins $HDLCODERIPINST/AXI4_Lite_ACLK] [get_bd_pins clkdiv/clk_out]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins clkdiv_reset/peripheral_aresetn]] [get_bd_pins $HDLCODERIPINST/AXI4_Lite_ARESETN] [get_bd_pins clkdiv_reset/peripheral_aresetn]
connect_bd_intf_net [get_bd_intf_pins $HDLCODERIPINST/AXI4_Lite] [get_bd_intf_pins axi_cpu_interconnect/M06_AXI]
create_bd_addr_seg -range 0x10000 -offset 0x43C00000 [get_bd_addr_spaces sys_ps7/Data] [get_bd_addr_segs $HDLCODERIPINST/AXI4_Lite/reg0] SEG_${HDLCODERIPINST}_reg0

connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins util_ad9361_adc_pack/adc_valid_0]] [get_bd_pins $HDLCODERIPINST/dut_data_valid] [get_bd_pins util_ad9361_adc_pack/adc_valid_0]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins util_ad9361_adc_pack/adc_data_0]] [get_bd_pins $HDLCODERIPINST/dut_data_0] [get_bd_pins util_ad9361_adc_pack/adc_data_0]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins util_ad9361_adc_pack/adc_data_1]] [get_bd_pins $HDLCODERIPINST/dut_data_1] [get_bd_pins util_ad9361_adc_pack/adc_data_1]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins util_ad9361_adc_fifo/dout_data_0]] [get_bd_pins $HDLCODERIPINST/sys_wfifo_0_dma_wdata] [get_bd_pins util_ad9361_adc_fifo/dout_data_0]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins util_ad9361_adc_fifo/dout_data_1]] [get_bd_pins $HDLCODERIPINST/sys_wfifo_1_dma_wdata] [get_bd_pins util_ad9361_adc_fifo/dout_data_1]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins clkdiv/clk_out]] [get_bd_pins $HDLCODERIPINST/IPCORE_CLK] [get_bd_pins clkdiv/clk_out]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins clkdiv_reset/peripheral_aresetn]] [get_bd_pins $HDLCODERIPINST/IPCORE_RESETN] [get_bd_pins clkdiv_reset/peripheral_aresetn]
add_files -norecurse {projects/pzsdr2/ccbrk_lvds/system_top.v}
update_compile_order -fileset sources_1
validate_bd_design
save_bd_design
add_files -fileset constrs_1 -norecurse projects/pzsdr2/common/ccbrk_constr.xdc projects/pzsdr2/common/pzsdr2_constr.xdc projects/pzsdr2/common/pzsdr2_constr_lvds.xdc
close_project
exit
