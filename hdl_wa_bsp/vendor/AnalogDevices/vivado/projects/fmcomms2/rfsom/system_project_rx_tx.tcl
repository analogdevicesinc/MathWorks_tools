set ad_hdl_dir    	[pwd]
set ad_phdl_dir   	[pwd]
set proj_dir		$ad_hdl_dir/projects/fmcomms2/rfsom

source $ad_hdl_dir/projects/scripts/adi_project.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

adi_project_create fmcomms2_rfsom $proj_dir config_rx_tx.tcl

adi_project_files fmcomms2_rfsom [list \
  "system_top.v" \
  "system_constr.xdc"\
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/common/rfsom/rfsom_system_constr.xdc" ]
  
set_property PROCESSING_ORDER EARLY [get_files $ad_hdl_dir/projects/common/rfsom/rfsom_system_constr.xdc]
set_property PROCESSING_ORDER EARLY [get_files system_constr.xdc]

adi_project_run fmcomms2_rfsom