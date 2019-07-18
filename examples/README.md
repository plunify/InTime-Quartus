# Examples 

### [autorun-multi-recipes](autorun_multi_recipes/)

This is an example of how to develop and run custom Tcl scripts to automate the InTime software. There are several ways of running InTime; some users like to use the graphical user interface and others prefer command-line scripting. Advanced users can create
custom Tcl scripts to automatically try different InTime Recipes to keep InTime running optimizations in the background.

The full explanation of how this works can be found in the application note [PIN003 Scripting Tcl in InTime](https://support.plunify.com/en/download/26391/).

A full reference guide to Tcl commands is found [here](https://support.plunify.com/en/doc/intime-doc/tcl-command-reference/). 

## How to run in InTime Tcl Console

1. Start InTime and open the project 
```
./autorun_multi_recipes/eight_bit_16p0_std/eight_bit_uc.qpf
```

2. Go to the InTime Tcl Console, type 
```
source ../autorun_multi_recipes.tcl
```

## How to run in command-line
1. Change directory to `autorun_multi_recipes/eight_bit_uc_16p0_std`

```
cd autorun_multi_recipes/eight_bit_uc_16p0_std
```

2. Run the following command in command-line

For Linux
``` 
<intime_installed_dir>/intime.sh -project eight_bit_uc.qpf -mode batch -s ../autorun_multi_recipes.tcl -toolchain quartusii -toolchain_version 16.0.0 -tclargs “-output_dir <output directory>”
```

For Window 
```
<intime_installed_dir>\bin\intime.exe -project eight_bit_uc.qpf -mode batch -s ../autorun_multi_recipes.tcl -toolchain quartusii -toolchain_version 16.0.0 -tclargs “-output_dir <output directory>”
```
