#----------------------------------------------------------------------
# Script      : intimeflow.tcl
# Description : Runs an InTime recipe
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

# Sample script for InTime Optimization. Works Windows & Linux
flow reset
# Build machine(s): local or private_cloud or plunify_cloud
flow set run_target local
# Number of generated strategies
flow set runs_per_round 40
flow set rounds 1
# Number of builds in parallel
flow set concurrent_runs 8
flow set control_create_bitstreams false
flow load_recipe "hot_start"
flow run_recipe "hot_start"
