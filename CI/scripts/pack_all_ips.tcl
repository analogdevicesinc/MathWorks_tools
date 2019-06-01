
# Create zip of IP cores
proc pack_ip_core {} {

  set folder_list [glob -types d *]

  foreach dir $folder_list {
  	puts "$dir"
  	cd $dir

  	if {[catch {set fp [open ${dir}_ip.tcl r]}]} {
  		cd ..
  		continue
  	}
  	close $fp

  	set fp [open ${dir}_ip.tcl a+]
  	puts -nonewline $fp "ipx::archive_core -verbose {analog.com_user_"
  	puts -nonewline $fp "$dir"
  	puts -nonewline $fp "_1.0.zip} \[ipx::current_core\]"
  	close $fp

  	source ./${dir}_ip.tcl

  	cd ..
  }
}

source hdl/library/scripts/adi_ip.tcl
source hdl/library/scripts/adi_env.tcl

cd hdl

# Pack main library cores
cd library
pack_ip_core

# Pack Xilinx cores
cd xilinx
pack_ip_core
cd ..

# Pack JESD cores
cd jesd204
pack_ip_core
cd ..

# Pack spi_engine cores
cd spi_engine
pack_ip_core
cd ..

cd ../../
