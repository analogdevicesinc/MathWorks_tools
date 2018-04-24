set cdir [pwd]
set sdk_loc $cdir/vivado_prj.sdk

# Create the SDK project
hsi open_hw_design $sdk_loc/system_top.hdf
set cpu_name [lindex [hsi get_cells -filter {IP_TYPE==PROCESSOR}] 0] 
sdk set_workspace $sdk_loc
sdk create_hw_project -name hw_0 -hwspec $sdk_loc/system_top.hdf
sdk create_app_project -name fsbl -hwproject hw_0 -proc $cpu_name -os standalone -lang C -app {Zynq FSBL}
sdk build_project -type all

# Create the BOOT.bin
exec bootgen -image $cdir/boot/zynq.bif -w -o i $cdir/boot/BOOT.BIN
