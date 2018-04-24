
set req_clk [get_clocks -of_objects [get_ports s_axi_aclk]]
set src_clk [get_clocks -of_objects [get_ports -quiet {fifo_wr_clk s_axis_aclk m_src_axi_aclk}]]
set dest_clk [get_clocks -of_objects [get_ports -quiet {fifo_rd_clk m_axis_aclk m_dest_axi_aclk}]]

set_property ASYNC_REG TRUE \
	[get_cells -quiet -hier *cdc_sync_stage1_reg*] \
	[get_cells -quiet -hier *cdc_sync_stage2_reg*]

set_max_delay -quiet -datapath_only \
	-from $req_clk \
	-to [get_cells -quiet -hier *cdc_sync_stage1_reg* \
		-filter {NAME =~ *i_sync_src_request_id* && IS_SEQUENTIAL}] \
	[get_property -min PERIOD $req_clk]

set_false_path -quiet \
	-from $src_clk \
	-to [get_cells -quiet -hier *cdc_sync_stage1_reg* \
		-filter {NAME =~ *i_sync_status_src* && IS_SEQUENTIAL}]

set_false_path -quiet \
	-from $req_clk \
	-to [get_cells -quiet -hier *cdc_sync_stage1_reg* \
		-filter {NAME =~ *i_sync_control_src* && IS_SEQUENTIAL}]

set_max_delay -quiet -datapath_only \
	-from $req_clk \
	-to [get_cells -quiet -hier *cdc_sync_stage1_reg* \
		-filter {NAME =~ *i_src_req_fifo/i_waddr_sync* && IS_SEQUENTIAL}] \
	[get_property -min PERIOD $req_clk]

set_max_delay -quiet -datapath_only \
	-from $src_clk \
	-to [get_cells -quiet -hier *cdc_sync_stage1_reg* \
		-filter {NAME =~ *i_src_req_fifo/i_raddr_sync* && IS_SEQUENTIAL}] \
	[get_property -min PERIOD $src_clk]

set_max_delay -quiet -datapath_only \
	-from [get_cells -quiet -hier *cdc_sync_fifo_ram_reg* \
		-filter {NAME =~ *i_src_req_fifo* && IS_SEQUENTIAL}] \
	-to $src_clk \
	[get_property -min PERIOD $src_clk]

set_max_delay -quiet -datapath_only \
	-from [get_cells -quiet -hier *eot_mem_reg* \
		-filter {NAME =~ *i_request_arb* && IS_SEQUENTIAL}] \
	-to $src_clk \
	[get_property -min PERIOD $src_clk]

set_max_delay -quiet -datapath_only \
	-from $src_clk \
	-to [get_cells -quiet -hier *cdc_sync_stage1_reg* \
		-filter {NAME =~ *i_sync_dest_request_id* && IS_SEQUENTIAL}] \
	[get_property -min PERIOD $src_clk]

set_max_delay -quiet -datapath_only \
	-from $src_clk \
	-to [get_cells -quiet -hier *cdc_sync_stage1_reg* \
		-filter {NAME =~ *i_fifo/i_address_gray/i_waddr_sync* && IS_SEQUENTIAL}] \
	[get_property -min PERIOD $src_clk]

set_max_delay -quiet -datapath_only \
	-from $dest_clk \
	-to [get_cells -quiet -hier *cdc_sync_stage1_reg* \
		-filter {NAME =~ *i_fifo/i_address_gray/i_raddr_sync* && IS_SEQUENTIAL}] \
	[get_property -min PERIOD $dest_clk]

# In SDP mode REGCEB should not be connected. When inferring the BRAM the tools
# do it anyway. The signal is not used by the BRAM though. But since the clock
# associated with REGCEB is the write clock and not the read clock we get a
# timing problem. Mark the path as a false path so it is not timed.
set_false_path -quiet \
	-to [get_pins -hier *ram_reg*/REGCEB -filter {NAME =~ *i_fifo*}]

# Reset signals
set_false_path -quiet \
	-from $req_clk \
	-to [get_pins -quiet -hier *reset_shift_reg*/PRE]

# Ignore timing for debug signals to register map
set_false_path -quiet \
	-from [get_cells -quiet -hier *cdc_sync_stage2_reg* \
		-filter {name =~ *i_sync_src_request_id* && IS_SEQUENTIAL}] \
	-to [get_cells -quiet -hier *up_rdata_reg* -filter {IS_SEQUENTIAL}]
set_false_path -quiet \
	-from [get_cells -quiet -hier *cdc_sync_stage2_reg* \
		-filter {name =~ *i_sync_dest_request_id* && IS_SEQUENTIAL}] \
	-to [get_cells -quiet -hier *up_rdata_reg* -filter {IS_SEQUENTIAL}]
set_false_path -quiet \
	-from [get_cells -quiet -hier *id_reg* -filter {name =~ *i_request_arb* && IS_SEQUENTIAL}] \
	-to [get_cells -quiet -hier *up_rdata_reg* -filter {IS_SEQUENTIAL}]
set_false_path -quiet \
	-from [get_cells -quiet -hier *address_reg* -filter {name =~ *i_addr_gen* && IS_SEQUENTIAL}] \
	-to [get_cells -quiet -hier *up_rdata_reg* -filter {IS_SEQUENTIAL}]
