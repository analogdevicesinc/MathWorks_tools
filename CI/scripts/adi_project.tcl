
variable p_board
variable p_device
variable sys_zynq
variable p_prcfg_init
variable p_prcfg_list
variable p_prcfg_status

if {![info exists REQUIRED_VIVADO_VERSION]} {
  set REQUIRED_VIVADO_VERSION "2018.2"
}

if {[info exists ::env(ADI_IGNORE_VERSION_CHECK)]} {
  set IGNORE_VERSION_CHECK 1
} elseif {![info exists IGNORE_VERSION_CHECK]} {
  set IGNORE_VERSION_CHECK 0
}

set p_board "not-applicable"
set p_device "none"
set sys_zynq 1
set ADI_POWER_OPTIMIZATION 0

proc adi_project_xilinx {project_name project_dir update_tcl {mode 0}} {

  global ad_hdl_dir
  global ad_phdl_dir
  global p_board
  global p_device
  global sys_zynq
  global REQUIRED_VIVADO_VERSION
  global IGNORE_VERSION_CHECK

  if [regexp "_ac701$" $project_name] {
    set p_device "xc7a200tfbg676-2"
    set p_board "xilinx.com:ac701:part0:1.0"
    set sys_zynq 0
  }
  if [regexp "_kc705$" $project_name] {
    set p_device "xc7k325tffg900-2"
    set p_board "xilinx.com:kc705:part0:1.1"
    set sys_zynq 0
  }
  if [regexp "_vc707$" $project_name] {
    set p_device "xc7vx485tffg1761-2"
    set p_board "xilinx.com:vc707:part0:1.1"
    set sys_zynq 0
  }
  if [regexp "_kcu105$" $project_name] {
    set p_device "xcku040-ffva1156-2-e"
    set p_board "xilinx.com:kcu105:part0:1.1"
    set sys_zynq 0
  }
  if [regexp "_zed$" $project_name] {
    set p_device "xc7z020clg484-1"
    set p_board "em.avnet.com:zed:part0:1.3"
    set sys_zynq 1
  }
  if [regexp "_microzed$" $project_name] {
    set p_device "xc7z010clg400-1"
    set p_board "not-applicable"
    set sys_zynq 1
  }
  if [regexp "_zc702$" $project_name] {
    set p_device "xc7z020clg484-1"
    set p_board "xilinx.com:zc702:part0:1.2"
    set sys_zynq 1
  }
  if [regexp "_zc706$" $project_name] {
    set p_device "xc7z045ffg900-2"
    set p_board "xilinx.com:zc706:part0:1.2"
    set sys_zynq 1
  }
  if [regexp "_mitx045$" $project_name] {
    set p_device "xc7z045ffg900-2"
    set p_board "not-applicable"
    set sys_zynq 1
  }
  if [regexp "_zcu102$" $project_name] {
    set p_device "xczu9eg-ffvb1156-2-e"
    set p_board "xilinx.com:zcu102:part0:3.1"
    set sys_zynq 2
  }

  #Added
  set project_name_org $project_name
  set project_name vivado_prj
  
  set VIVADO_VERSION [version -short]
  if {[string compare $VIVADO_VERSION $REQUIRED_VIVADO_VERSION] != 0} {
    puts -nonewline "CRITICAL WARNING: vivado version mismatch; "
    puts -nonewline "expected $REQUIRED_VIVADO_VERSION, "
    puts -nonewline "got $VIVADO_VERSION.\n"
  }

  #Added
  adi_setup_libs
  
  if {$mode == 0} {
    set project_system_dir "./$project_name.srcs/sources_1/bd/system"
    #Removed
	#create_project $project_name . -part $p_device -force
  } else {
    set project_system_dir ".srcs/sources_1/bd/system"
    #Removed
	#create_project -in_memory -part $p_device
  }

  if {$mode == 1} {
    file mkdir $project_name.data
  }

  if {$p_board ne "not-applicable"} {
    set_property board_part $p_board [current_project]
  }

  #Removed
  #set lib_dirs $ad_hdl_dir/library
  #if {$ad_hdl_dir ne $ad_phdl_dir} {
  #  lappend lib_dirs $ad_phdl_dir/library
  #}

  #set_property ip_repo_paths $lib_dirs [current_fileset]
  #update_ip_catalog

  set_msg_config -id {BD 41-1348} -new_severity info
  set_msg_config -id {BD 41-1343} -new_severity info
  set_msg_config -id {BD 41-1306} -new_severity info
  set_msg_config -id {IP_Flow 19-1687} -new_severity info
  set_msg_config -id {filemgmt 20-1763} -new_severity info
  set_msg_config -severity {CRITICAL WARNING} -quiet -id {BD 41-1276} -new_severity error

  #Added
  create_bd_design "system"
  source $project_dir/system_bd.tcl
  if {$project_name_org != "adrv9361z7035_ccbox_lvds_modem"} {
    source $project_dir/$update_tcl
  }
 
 
  regenerate_bd_layout
  save_bd_design
  validate_bd_design

  set_property synth_checkpoint_mode None [get_files  $project_system_dir/system.bd]
  generate_target {synthesis implementation} [get_files  $project_system_dir/system.bd]
  make_wrapper -files [get_files $project_system_dir/system.bd] -top

  if {$mode == 0} {
    import_files -force -norecurse -fileset sources_1 $project_system_dir/hdl/system_wrapper.v
  } else {
    write_hwdef -file "$project_name.data/$project_name.hwdef"
  }
}

#Added
proc adi_setup_libs {} {
  global ad_hdl_dir
  global ad_phdl_dir 

  set lib_dirs [get_property ip_repo_paths [current_fileset]]
  
  lappend lib_dirs $ad_hdl_dir/library
  if {$ad_hdl_dir ne $ad_phdl_dir} {
    lappend lib_dirs $ad_phdl_dir/library
  }
  
  set_property ip_repo_paths $lib_dirs [current_fileset]
  update_ip_catalog
  adi_add_archive_ip $lib_dirs
}

#Added
proc adi_add_archive_ip {lib_dirs} {
  global ad_hdl_dir
  global ad_phdl_dir 
  foreach libDir $lib_dirs {
    set ipList [glob -nocomplain -directory $libDir *.zip]
    foreach ipCore $ipList {
      catch {update_ip_catalog -add_ip $ipCore -repo_path $libDir}
	  file delete -force $ipCore	  
    }
  }
}

proc adi_project_files {project_name project_files} {
  
  global ad_hdl_dir
  global ad_phdl_dir
  global proj_dir
  
  #Added
  cd $proj_dir
  
  add_files -norecurse -fileset sources_1 $project_files
  set_property top system_top [current_fileset]
  
  #Added
  cd $ad_hdl_dir
}

proc adi_project_run {project_name} {
  #Removed
}

