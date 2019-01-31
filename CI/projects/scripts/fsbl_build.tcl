
if { $argc != 3 } {
    set fpga_board "ZC706"
} else {
    set fpga_board [lindex $argv 1]
}
puts "==========="
puts $fpga_board
puts "==========="

set cdir [pwd]
set sdk_loc $cdir/vivado_prj.sdk

# Create the SDK project
hsi open_hw_design $sdk_loc/system_top.hdf
set cpu_name [lindex [hsi get_cells -filter {IP_TYPE==PROCESSOR}] 0] 
sdk set_workspace $sdk_loc
sdk create_hw_project -name hw_0 -hwspec $sdk_loc/system_top.hdf

# Create project
if {$fpga_board eq "ZCU102"} {
    sdk create_app_project -name fsbl -hwproject hw_0 -proc $cpu_name -os standalone -lang C -app {Zynq MP FSBL}
} else {
    sdk create_app_project -name fsbl -hwproject hw_0 -proc $cpu_name -os standalone -lang C -app {Zynq FSBL}
}

sdk configapp -app fsbl build-config release
sdk build_project -type all

# Collect necessary files
file copy -force $cdir/projects/common/boot/zynq.bif $cdir/boot/zynq.bif
file copy -force $sdk_loc/fsbl/Release/fsbl.elf $cdir/boot/fsbl.elf
file copy -force $sdk_loc/hw_0/system_top.bit $cdir/boot/system_top.bit
cd $cdir/boot

# Create the BOOT.bin
if {$fpga_board eq "ZCU102"} {
exec bootgen -image $cdir/boot/zynqmp.bif -w -o i $cdir/boot/BOOT.BIN
} else {
exec bootgen -image $cdir/boot/zynq.bif -w -o i $cdir/boot/BOOT.BIN
}
