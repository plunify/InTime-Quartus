# Run InTime in Vivado Tcl Console

**Note** If you have not configured your InTime environment, please go to [configuration](../intime/configuration/)

## Steps
1. Edit [`start_intime_vivado_windows.tcl`](start_intime_vivado_windows.tcl) or [`start_intime_vivado_linux.tcl`](start_intime_vivado_linux.tcl) script to configure the environment, e.g. project path etc. 

```Tcl
#
# Specify InTime and project paths
#
set yourintimetoolpath "/v2.6.11/bin/intime.exe"
set yourproject "/yourproject/eight_bit_uc.xpr"
```
```Tcl
#
# Specify your FPGA tool version
# The following assumes that you have registered your tool in InTime.
#
set yourtool "vivado"
set yourtoolchain "2018.2.0"
```

```Tcl
# Specify the InTime Tcl script 
# Download a sample from https://github.com/plunify/InTime-Vivado/tree/master/scripts/intime
#
set yourintimescript "/yourproject/intimeflow.tcl"
```


2. Open the Vivado Tcl Console and source the script.
![alt text](https://github.com/plunify/InTime/blob/master/images/VivadoTclConsole_windows.png "Vivado Tcl Console - Windows") 
3. Note that an InTime optimization script called [intimeflow.tcl](../intime/intimeflow.tcl) will be required. 
