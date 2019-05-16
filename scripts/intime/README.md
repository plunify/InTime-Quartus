# InTime Scripts

## Contents

1. `intimetclflow.tcl` is a sample script showing how to run InTime using Tcl instead of the GUI. 

```Tcl
# Sample script for InTime Optimization. Works Windows & Linux
flow reset
flow set run_target local
flow set runs_per_round 2
flow set rounds 1
flow set concurrent_runs 1
flow set control_create_bitstreams false
flow run_recipe "hot_start"
```

A more detailed version of the Tcl reference for InTime can be found at this [link](https://docs.plunify.com/intime/flow_properties.html)  

