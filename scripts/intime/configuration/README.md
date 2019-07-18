# Configure FPGA toolchains in InTime with Tcl

You can either use the Quartus Tcl Console or the command-line terminal / Command Prompt to do this. 


## Option A: Use Quartus Tcl Console
1. Download [intime_install_FPGA_tools.tcl](intime_install_FPGA_tools.tcl) & [configure_tools.tcl](configure_tools.tcl)

2. Edit the `intime_install_FPGA_tools.tcl`to specify the installation path to the FPGA toolchains and their respective licenses. Multiple toolchains can be configured at the same time.

```Tcl
set yourtoolchainpath(0) "/mnt/opt/altera/16.0.0/quartus"
set yourtoolchainlicense(0) "/mnt/license_file.lic"

#
# If you have multiple toolchains, use an array to specify them
#
# set yourtoolchainpath(1) "/mnt/opt/altera/16.1.0/quartus"
# set yourtoolchainlicense(1) "/mnt/license_file.lic"

# set yourtoolchainpath(2) ""
# set yourtoolchainlicense(2) ""
```

3. Edit the `configure_tools.tcl` and specify the InTime installation path in the **yourintimetoolpath** variable.

```Tcl
#################################################################################
#
#	Tcl script to configure the environment for InTime 
#
#################################################################################

# InTime installation path
set yourintimetoolpath "intime.exe"
```

4. Open the Vivado Tcl Console and enter 
```console
source configure_tools.tcl
```

5. When it completes successfully, you should see a list of currently installed tools. (See below) 

![alt text](https://github.com/plunify/InTime/blob/master/images/Vivado_tcl_console_tool_list.png)

## Option B: Using a CLi
1. Edit the [intime_install_FPGA_tools.tcl](intime_install_FPGA_tools.tcl) to specify the installation path to the FPGA toolchains and their respective licenses. Multiple toolchains can be configured at the same time.

```Tcl
set yourtoolchainpath(0) "/mnt/opt/altera/16.0.0/quartus"
set yourtoolchainlicense(0) "/mnt/license_file.lic"

#
# If you have multiple toolchains, use an array to specify them
#
# set yourtoolchainpath(1) "/mnt/opt/altera/16.1.0/quartus"
# set yourtoolchainlicense(1) "/mnt/license_file.lic"

# set yourtoolchainpath(2) ""
# set yourtoolchainlicense(2) ""
```

2. Open the command-line interface, and run the command

**In Windows**

```console
"C:/Program Files/Plunify/InTime/v2.6.11/bin/intime.exe" -mode batch -platform minimal 
-s intime_install_FPGA_tools.tcl
```

**In Linux**

Change the above command to execute intime.sh instead. The output should be the same as when executing in the Quartus Tcl Console.
```console
"/mnt/intime/intime.sh" -mode batch -platform minimal -s intime_install_FPGA_tools.tcl
```

This shoud configure InTime to recognize where are the FPGA tools and licenses.

For more information, please refer to InTime [documentation](https://docs.plunify.com/intime/configuration.html)
