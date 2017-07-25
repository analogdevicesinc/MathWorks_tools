proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
set_msg_config  -ruleid {1}  -id {BD 41-1348}  -new_severity {INFO} 
set_msg_config  -ruleid {2}  -id {BD 41-1343}  -new_severity {INFO} 
set_msg_config  -ruleid {3}  -id {BD 41-1306}  -new_severity {INFO} 
set_msg_config  -ruleid {4}  -id {IP_Flow 19-1687}  -new_severity {INFO} 
set_msg_config  -ruleid {5}  -id {filemgmt 20-1763}  -new_severity {INFO} 
set_msg_config  -ruleid {6}  -id {BD 41-1276}  -severity {CRITICAL WARNING}  -new_severity {ERROR} 

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  set_property design_mode GateLvl [current_fileset]
  set_param project.singleFileAddWarning.threshold 0
  set_property webtalk.parent_dir C:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.cache/wt [current_project]
  set_property parent.project_path C:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.xpr [current_project]
  set_property ip_repo_paths {
  c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.cache/ip
  C:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/ipcore
  C:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/library
} [current_project]
  set_property ip_output_repo c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.cache/ip [current_project]
  set_property XPM_LIBRARIES XPM_CDC [current_project]
  add_files -quiet C:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.runs/synth_1/system_top.dcp
  read_xdc -ref system_sys_ps7_0 -cells inst c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_sys_ps7_0/system_sys_ps7_0.xdc
  set_property processing_order EARLY [get_files c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_sys_ps7_0/system_sys_ps7_0.xdc]
  read_xdc -prop_thru_buffers -ref system_axi_iic_main_0 -cells U0 c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_axi_iic_main_0/system_axi_iic_main_0_board.xdc
  set_property processing_order EARLY [get_files c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_axi_iic_main_0/system_axi_iic_main_0_board.xdc]
  read_xdc -prop_thru_buffers -ref system_sys_rstgen_0 -cells U0 c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_sys_rstgen_0/system_sys_rstgen_0_board.xdc
  set_property processing_order EARLY [get_files c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_sys_rstgen_0/system_sys_rstgen_0_board.xdc]
  read_xdc -ref system_sys_rstgen_0 -cells U0 c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_sys_rstgen_0/system_sys_rstgen_0.xdc
  set_property processing_order EARLY [get_files c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_sys_rstgen_0/system_sys_rstgen_0.xdc]
  read_xdc -prop_thru_buffers -ref system_clkdiv_reset_0 -cells U0 c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_clkdiv_reset_0/system_clkdiv_reset_0_board.xdc
  set_property processing_order EARLY [get_files c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_clkdiv_reset_0/system_clkdiv_reset_0_board.xdc]
  read_xdc -ref system_clkdiv_reset_0 -cells U0 c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_clkdiv_reset_0/system_clkdiv_reset_0.xdc
  set_property processing_order EARLY [get_files c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_clkdiv_reset_0/system_clkdiv_reset_0.xdc]
  read_xdc C:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/projects/pzsdr2/common/ccbrk_constr.xdc
  read_xdc C:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/projects/pzsdr2/common/pzsdr2_constr.xdc
  read_xdc C:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/projects/pzsdr2/common/pzsdr2_constr_lvds.xdc
  read_xdc C:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/projects/common/xilinx/compression_system_constr.xdc
  read_xdc C:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/projects/pzsdr2/common/pzsdr2_constr.xdc
  read_xdc C:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/projects/pzsdr2/common/pzsdr2_constr_lvds.xdc
  read_xdc C:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/projects/pzsdr2/common/ccbrk_constr.xdc
  read_xdc -unmanaged c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ipshared/analog.com/axi_dmac_v1_0/bd.tcl
  read_xdc -unmanaged c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ipshared/analog.com/axi_dmac_v1_0/bd.tcl
  read_xdc -ref system_axi_ad9361_0 -cells inst c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_axi_ad9361_0/axi_ad9361_constr.xdc
  set_property processing_order LATE [get_files c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_axi_ad9361_0/axi_ad9361_constr.xdc]
  read_xdc -ref system_axi_ad9361_0 -cells inst c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_axi_ad9361_0/ad_axi_ip_constr.xdc
  set_property processing_order LATE [get_files c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_axi_ad9361_0/ad_axi_ip_constr.xdc]
  read_xdc -ref system_axi_ad9361_dac_dma_0 -cells inst c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_axi_ad9361_dac_dma_0/system_axi_ad9361_dac_dma_0_constr.xdc
  set_property processing_order LATE [get_files c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_axi_ad9361_dac_dma_0/system_axi_ad9361_dac_dma_0_constr.xdc]
  read_xdc -ref system_util_ad9361_dac_upack_0 -cells inst c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_util_ad9361_dac_upack_0/util_upack_constr.xdc
  set_property processing_order LATE [get_files c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_util_ad9361_dac_upack_0/util_upack_constr.xdc]
  read_xdc -ref system_axi_ad9361_adc_dma_0 -cells inst c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_axi_ad9361_adc_dma_0/system_axi_ad9361_adc_dma_0_constr.xdc
  set_property processing_order LATE [get_files c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_axi_ad9361_adc_dma_0/system_axi_ad9361_adc_dma_0_constr.xdc]
  read_xdc -ref system_util_ad9361_adc_pack_0 -cells inst c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_util_ad9361_adc_pack_0/util_cpack_constr.xdc
  set_property processing_order LATE [get_files c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_util_ad9361_adc_pack_0/util_cpack_constr.xdc]
  read_xdc -ref system_util_ad9361_adc_fifo_0 -cells inst c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_util_ad9361_adc_fifo_0/util_wfifo_constr.xdc
  set_property processing_order LATE [get_files c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_util_ad9361_adc_fifo_0/util_wfifo_constr.xdc]
  read_xdc -ref system_util_ad9361_tdd_sync_0 -cells inst c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_util_ad9361_tdd_sync_0/util_tdd_sync_constr.xdc
  set_property processing_order LATE [get_files c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_util_ad9361_tdd_sync_0/util_tdd_sync_constr.xdc]
  read_xdc -ref system_clkdiv_0 -cells inst c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_clkdiv_0/util_clkdiv_constr.xdc
  set_property processing_order LATE [get_files c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_clkdiv_0/util_clkdiv_constr.xdc]
  read_xdc -ref system_dac_fifo_0 -cells inst c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_dac_fifo_0/util_rfifo_constr.xdc
  set_property processing_order LATE [get_files c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_dac_fifo_0/util_rfifo_constr.xdc]
  read_xdc -ref system_axi_pz_xcvrlb_0 -cells inst c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_axi_pz_xcvrlb_0/axi_xcvrlb_constr.xdc
  set_property processing_order LATE [get_files c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_axi_pz_xcvrlb_0/axi_xcvrlb_constr.xdc]
  read_xdc -ref system_auto_cc_0 -cells inst c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_auto_cc_0/system_auto_cc_0_clocks.xdc
  set_property processing_order LATE [get_files c:/Users/acozma/Documents/GitHub/MathWorks_tools/targeting_models/ADSB/hdl_prj/vivado_ip_prj/vivado_prj.srcs/sources_1/bd/system/ip/system_auto_cc_0/system_auto_cc_0_clocks.xdc]
  link_design -top system_top -part xc7z035ifbg676-2L
  write_hwdef -file system_top.hwdef
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  opt_design 
  write_checkpoint -force system_top_opt.dcp
  report_drc -file system_top_drc_opted.rpt
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  implement_debug_core 
  place_design 
  write_checkpoint -force system_top_placed.dcp
  report_io -file system_top_io_placed.rpt
  report_utilization -file system_top_utilization_placed.rpt -pb system_top_utilization_placed.pb
  report_control_sets -verbose -file system_top_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force system_top_routed.dcp
  report_drc -file system_top_drc_routed.rpt -pb system_top_drc_routed.pb
  report_timing_summary -warn_on_violation -max_paths 10 -file system_top_timing_summary_routed.rpt -rpx system_top_timing_summary_routed.rpx
  report_power -file system_top_power_routed.rpt -pb system_top_power_summary_routed.pb -rpx system_top_power_routed.rpx
  report_route_status -file system_top_route_status.rpt -pb system_top_route_status.pb
  report_clock_utilization -file system_top_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

