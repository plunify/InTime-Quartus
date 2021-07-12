#----------------------------------------------------------------------
# Script      : get_results.tcl
# Description : Retrieves InTime recipe results
# Author      : Plunify
# Version     : 1.0
#               
# Return : None
#
# Usage :
#    1. Via the InTime Tcl console
#       % source <script.tcl>
#
#    2. Via Command-line
#       % intime.sh -mode batch -platform minimal -s <script.tcl>
#----------------------------------------------------------------------

# Clear the active results set and add all results of the current project
results clear
results add all

# Get the number of successful compilations
set numSuccess [results summary success -count]
# Get a quick summary
results summary
# Get the top 10 results in terms of TNS into a list
# To return all results, use: results summary all -list all_types -metric wns -id
# To return the top 10 results, use: results summary top10 -list all_types -metric wns -id
set resultsList [results summary top10 -list -all_types -metric wns -id]
# Returns a Tcl list like this: "2:hotstart_001" "1:eight_bit_uc_nonproj" "1:placement_1" "2:placement_1"

# Start examining the best result
strategy set_active hotstart_001 2
# Print the TNS
strategy results -field "TNS"
# Print the WNS
strategy results -field "Worst Setup"
# Print the logic utilization
strategy results -field "Area"
