

### Calling script must have system_top.hdf u-boot.elf


set cdir [pwd]
set sdk_loc $cdir/vivado_prj.sdk

### Create fsbl
hsi open_hw_design $sdk_loc/system_top.hdf
set cpu_name [lindex [hsi get_cells -filter {IP_TYPE==PROCESSOR}] 0]
sdk setws $sdk_loc
sdk createhw -name hw_0 -hwspec $sdk_loc/system_top.hdf
sdk createapp -name fsbl -hwproject hw_0 -proc $cpu_name -os standalone -lang C -app {Zynq MP FSBL}
configapp -app fsbl build-config release
sdk projects -build -type all

### Create create_pmufw_project.tcl
#set hwdsgn [open_hw_design $sdk_loc/system_top.hdf]
#generate_app -hw $hwdsgn -os standalone -proc psu_pmu_0 -app zynqmp_pmufw -sw pmufw -dir pmufw

### Copy common zynqmp.bif and bl31.elf file
file copy -force $cdir/projects/common/boot/zynqmp.bif $cdir/boot/zynqmp.bif
file copy -force $cdir/projects/common/boot/bl31.elf $cdir/boot/bl31.elf

### Copy fsbl and system_top.bit into the output folder
file copy -force $sdk_loc/fsbl/Release/fsbl.elf $cdir/boot/fsbl.elf
file copy -force $sdk_loc/hw_0/system_top.bit $cdir/boot/system_top.bit
file copy -force $cdir/pmufw/executable.elf $cdir/boot/pmufw.elf

### Build BOOT.BIN
cd $cdir/boot
exec bootgen -arch zynqmp -image zynqmp.bif -o BOOT.BIN -w
exit
