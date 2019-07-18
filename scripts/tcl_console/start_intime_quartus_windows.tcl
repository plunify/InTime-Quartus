#################################################################################
#
#	Tcl script to run InTime in Quartus Project Mode (for Window)
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
set yourproject "C:/Users/youraccount/plunify/examples/quartusii/eight_bit_uc/eight_bit_uc.qpf"
#
# Specify your FPGA tool version
# The following assumes that you have registered your tool in InTime. (If not, refer to https://docs.plunify.com/intime/configuration.html)
#
set yourtool "quartusii"
set yourtoolchain "18.1.0"
#
# Specify the InTime Tcl script 
# To understand more about the Tcl API, refer to Flow Properties - https://docs.plunify.com/intime/flow_properties.html
# Download a sample from https://github.com/plunify/InTime-Quartus/tree/master/script/intime
#
set yourintimescript "../intime/intimeflow.tcl"


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

