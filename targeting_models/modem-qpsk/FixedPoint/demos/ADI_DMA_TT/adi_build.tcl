# Build the project
update_compile_order -fileset sources_1
reset_run impl_1
reset_run synth_1
launch_runs synth_1
wait_on_run synth_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

# Define local variables
set cdir [pwd]
set sdk_loc vivado_prj.sdk

# Export the hdf
file delete -force $sdk_loc
file mkdir $sdk_loc
file copy -force vivado_prj.runs/impl_1/system_top.sysdef $sdk_loc/system_top.hdf

# Close the Vivado project
close_project

# Create the BOOT.bin
exec xsdk -batch -source $cdir/projects/scripts/fsbl_build.tcl -wait

puts "------------------------------------"
puts "Embedded system build completed."
puts "You may close this shell."
puts "------------------------------------"
exit
