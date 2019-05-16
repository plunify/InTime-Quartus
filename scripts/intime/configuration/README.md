# Configure FPGA toolchains in InTime with Tcl

You can either use the Vivado Tcl Console or the command-line terminal / Command Prompt to do this. 

## Steps
1. Download the 2 scripts `configure_tools.tcl` 
2. Edit the `intime_install_FPGA_tools.tcl`to specify the installation path to the FPGA toolchains and their respective licenses. Multiple toolchains can be configured at the same time.

### Option A: Use Vivado Tcl Console
1. Download `intime_install_FPGA_tools.tcl` & `configure_tools.tcl`
2. Edit the `configure_tools.tcl` and specify the InTime installation path in the **yourintimetoolpath** variable.

```Tcl
#################################################################################
#
#	Tcl script to configure the environment for InTime 
#
#################################################################################

# InTime installation path
set yourintimetoolpath "intime.exe"
```

3. Open the Vivado Tcl Console and enter 
```console
source configure_tools.tcl
```

4. When it completes successfully, you should see a list of currently installed tools. (See below) 

![alt text](https://github.com/plunify/InTime/blob/master/images/Vivado_tcl_console_tool_list.png)

### Option B: Using a CLi
1. Edit the `configure_tools.tcl` and specify the InTime installation path in the **yourintimetoolpath** variable.

In Windows,

`"C:/Program Files/Plunify/InTime/v2.6.11/bin/intime.exe" -mode batch -platform minimal -s intime_install_FPGA_tools.tcl`

In Linux,

change the above command to execute intime.sh instead. The output should be the same as when executing in the Vivado Tcl Console.

For more information, please refer to InTime [documentation](https://docs.plunify.com/intime/configuration.html)
