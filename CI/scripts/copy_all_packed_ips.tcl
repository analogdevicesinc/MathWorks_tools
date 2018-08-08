

proc copy_all_packed_ips { DEST_FOLDER } {

	#set WD [pwd]
	#set DEST_FOLDER D:/Work/hdlbsp-master/vendor/AnalogDevices/vivado/library
	#set DEST_FOLDER $WD

	set folder_list [glob -types d *]
	foreach dir $folder_list {
		puts "$dir"
		cd $dir

		if {[catch {set files_list [glob *]}]} {
			cd ..
			continue
		}

		foreach file $files_list {
			set idx [string first .zip $file 1]
			if {$idx != -1} {
				file copy -force $file $DEST_FOLDER/$file
				puts $file
			}
		}
		cd ..

		# Don't remove these folders
		if {$dir=="common"} {continue}
		if {$dir=="interfaces"} {continue}
		if {$dir=="prcfg"} {continue}
		if {$dir=="scripts"} {continue}
		if {$dir=="xilinx"} {continue}
		if {$dir=="jesd204"} {continue}
		if {$dir=="spi_engine"} {continue}
		file delete -force -- $dir


	}

}

cd hdl

# Move main library core zips
cd library
set DEST [pwd]
puts $DEST
copy_all_packed_ips $DEST

# Move Xilinx core zips
cd xilinx
set DEST [pwd]
copy_all_packed_ips $DEST
cd ..

# Move jesd204 core zips
cd jesd204
set DEST [pwd]
copy_all_packed_ips $DEST
cd ..

# Move spi_engine core zips
cd spi_engine
set DEST [pwd]
copy_all_packed_ips $DEST


cd ../../..
