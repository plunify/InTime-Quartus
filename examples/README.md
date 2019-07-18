# Examples 

## List of examples

### 1. [autorun-multi-recipes](autorun_multi_recipes/)

This is an example of how to develop and run custom Tcl
scripts to automate the InTime software. There are several ways of running InTime; some users like to
use the graphical user interface and others prefer command-line scripting. Advanced users can create
custom Tcl scripts to automatically try different InTime Recipes and just keep InTime running
optimizations in the background.

## Run in Intime Tcl Console

1. Start InTIme and open the 
```
./autorun_multi_recipes/eight_bit_16p0_std/eight_bit_us.qpf
```

2. In Intime Tcl Console
```
source ../autorun_multi_recipes.tcl
```

## Run in commend-line
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


