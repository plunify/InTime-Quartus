#################################################################################
#
#	Tcl script to run InTime in Vivado Project Mode (for Window)
#
#################################################################################

#################################################################################
#
# Change the following section to reflect your design and environment
#
#################################################################################
#
# Specify InTime and project paths
#
set yourintimetoolpath "C:/Program Files/Plunify/InTime/v2.6.11/bin/intime.exe"
set yourproject "C:/Users/youraccount/plunify/examples/vivado/eight_bit_uc_xpr/eight_bit_uc.xpr"
#
# Specify your FPGA tool version
# The following assumes that you have registered your tool in InTime. (If not, refer to https://docs.plunify.com/intime/configuration.html)
#
set yourtool "vivado"
set yourtoolchain "2018.2.0"
#
# Specify the InTime Tcl script 
# To understand more about the Tcl API, refer to Flow Properties - https://docs.plunify.com/intime/flow_properties.html
# Download a sample from https://github.com/plunify/InTime
#
set yourintimescript "C:/yourproject/intimeflow.tcl"


#################################################################################
#
# Run InTime (do not change the following section)
#
#################################################################################
#Do not change. This executes InTime 
puts "Command Executed: \"$yourintimetoolpath\" -mode batch -platform minimal \
			-project ${yourproject} \
			-vendor_toolchain ${yourtool} \
			-vendor_toolchain_version ${yourtoolchain} \
			-s ${yourintimescript}"

eval exec "\"$yourintimetoolpath\" -mode batch -platform minimal \
			-project ${yourproject} \
			-vendor_toolchain ${yourtool} \
			-vendor_toolchain_version ${yourtoolchain} \
			-s ${yourintimescript}" >@ stdout

