# Run InTime in Quartus Tcl Console

**Note** If you have not configured your InTime environment, please go to [configuration](../intime/configuration/)

## Steps
1. Edit [`start_intime_vivado_windows.tcl`](start_intime_quartus_windows.tcl) or [`start_intime_quartus_linux.tcl`](start_intime_quartus_linux.tcl) script to configure the environment, e.g. project path etc. 

```Tcl
#
# Specify InTime and project paths
#
set yourintimetoolpath "/v2.6.11/bin/intime.exe"
set yourproject "/yourproject/eight_bit_uc.qpf"
```

```Tcl
#
# Specify your FPGA tool version
# The following assumes that you have registered your tool in InTime.
#
set yourtool "quartusii"
set yourtoolchain "18.1.0"
```

```Tcl
# Specify the InTime Tcl script 
# Download a sample from https://github.com/plunify/InTime-Quartus/tree/master/scripts/intime
#
set yourintimescript "/yourproject/intimeflow.tcl"
```

2. Open the Vivado Tcl Console and source the script.

![alt text](https://github.com/plunify/InTime/blob/master/images/VivadoTclConsole_windows.png "Quatus Tcl Console - Windows") 

3. Note that an InTime optimization script called [intimeflow.tcl](../intime/intimeflow.tcl) will be required. 
