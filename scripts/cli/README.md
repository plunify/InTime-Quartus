# Run InTime in Command Line Interface (CLi)

**Note** If you have not configured your InTime environment, please go to [configuration](../intime/configuration/)

## Steps

### Linux

**Option A: Use a shell script**

Edit the provided script [`start_intime_linux_shell.sh`](cli/start_intime_linux_shell.sh) to configure your environment.

```shell-script
###############################################################################################
# Configure your environment here
# You can get a sample intime script, e.g. intimeflow.tcl at https://github.com/plunify/InTime
###############################################################################################

YOURINTIMEPATH=""
YOURPROJECT=""
YOURFPGATOOL=""
YOURTOOLVERSION=""
YOURINTIMESCRIPT=""

# Example Values
# YOURINTIMEPATH="/home/dev2002/intime_v2.6.11/intime.sh"
# YOURPROJECT="/home/dev2002/plunify/examples/vivado/eight_bit_uc_xpr/eight_bit_uc.xpr"
# YOURFPGATOOL="vivado"
# YOURTOOLVERSION="2018.2.0"
# YOURINTIMESCRIPT="/home/dev2002/intimeflow.tcl"
```

After editing, just run it in the command line.
```console
$ ./start_intime_linux_shell.sh
```

**Option B: Run CLi directly**

```console
$ intime.sh -mode batch -platform minimal -project yourproject.xpr -vendor_toolchain vivado -vendor_toolchain_version 2018.3.0 -s intimeflow.tcl
```

### Windows

**Run CLi directly**
```console
"C:/intime.exe" -mode batch -platform minimal -project C:/yourproject.xpr -vendor_toolchain vivado -vendor_toolchain_version 2018.3.0 -s C:/intimeflow.tcl
```

**_Note_** In both OS, an InTime optimization script called [intimeflow.tcl](../intime/intimeflow.tcl) will be required.

### Arguments Description:
1. `intime.sh` or `intime.exe` - This is the location of intime.sh or intime.exe in your environment.
2. `-mode batch` - Tells InTime to operate in batch mode.
3. `-platform minimal` - Tells InTime to operate in non-GUI mode.
4. `-project` - Design to optimize. Specify your XPR, DCP or Tcl (for non-project mode) file.
5. `-vendor_toolchain` - Specify your FPGA vendor tools 
6. `-vendor_toolchain_version` - Use the specified Vivado version.
7. `-s` - Runs an InTime Tcl script. Change this to point to the InTime Tcl script.
8. `>@ stdout` Echo output to the terminal as InTime runs.


