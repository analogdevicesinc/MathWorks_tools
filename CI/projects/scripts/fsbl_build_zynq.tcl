

### Calling script must have system_top.hdf u-boot.elf


set cdir [pwd]
set sdk_loc $cdir/vivado_prj.sdk

### Create fsbl
hsi open_hw_design $sdk_loc/system_top.hdf
set cpu_name [lindex [hsi get_cells -filter {IP_TYPE==PROCESSOR}] 0]
sdk setws $sdk_loc
sdk createhw -name hw_0 -hwspec $sdk_loc/system_top.hdf
sdk createapp -name fsbl -hwproject hw_0 -proc $cpu_name -os standalone -lang C -app {Zynq FSBL}
configapp -app fsbl build-config release
sdk projects -build -type all

### Copy common zynq.bif file
file copy -force $cdir/projects/common/boot/zynq.bif $cdir/boot/zynq.bif

### Copy fsbl and system_top.bit into the output folder
file copy -force $sdk_loc/fsbl/Release/fsbl.elf $cdir/boot/fsbl.elf
file copy -force $sdk_loc/hw_0/system_top.bit $cdir/boot/system_top.bit

### Build BOOT.BIN
cd $cdir/boot
exec bootgen -arch zynq -image zynq.bif -o BOOT.BIN -w

