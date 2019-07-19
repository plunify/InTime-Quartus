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

## Explanation:
The autorun_multi_recipes.tcl example script is divided into five different parts:

- Variable declaration for important information like the recipes to use, TNS goal, number of runs per rounds, etc.
- InTime flow configuration and recipe execution.
- Results verification to either stop or execute subsequent recipes.
- Export strategies to Tcl scripts.
- Summarize and print results.


### A. Variable Declaration

First it describes what recipes to use and in what order of execution. In this example, for Quartus the order of execution is:
#### Hot Start -> InTime Default -> deep_dive -> seeded_effort_level_exploration

You can modify this sequence to use different recipes or to change the order of execution.

```Tcl
# Define order of recipes to execute. 
# -> Type 'flow recipes -supported' in Tcl console to show all available recipe's name
set current_toolchain [project info toolchain]
if { [string equal "$current_toolchain" "quartusii"] } {
    # Execution Order : hot_start > intime_default > deep_dive > seeded_effort_level_exploration
    set recipes_list [list "hot_start" "intime_default" "deep_dive" "seeded_effort_level_exploration" ]

} elseif { [string equal "$current_toolchain" "vivado"] } {
    set recipes_list [list "hot_start" "intime_default" "extra_opt_exploration"]

} else {
    set recipes_list [list "intime_default"]

}
```

The below part shows how to define the goals for Total Negative Slack(TNS), Worst Negative Slack (WNS) for each recipe, number of runs per round, number of rounds. ```end_tns_goal``` contains the final TNS goal. Upon reaching the final TNS goal, there can be various follow-on actions, for example generate bitstream, copy files, and so on.
```tcl
# Define end goal
set end_tns_goal 0
set end_wns_goal "*" ; #Don't Care
```

The ```recipe_target_result_tns``` defines a recipe goal that tells InTime to switch to a subsequent recipe if it meets this TNS target. Typically, the earlier goals are set at a worse level compared to the later goals.
```tcl
# Define tns goal for each recipe run
set recipe_target_result_tns(hot_start) "-2500"
set recipe_target_result_tns(intime_default) "-1000"
set recipe_target_result_tns(deep_dive) "-500"
set recipe_target_result_tns(auto_placement) "0"
set recipe_target_result_tns(seeded_effort_level_exploration) "0"
set recipe_target_result_tns(vivado_explorer) "0"
set recipe_target_result_tns(extra_opt_exploration) "0"
```
### B. InTime flow configuration and recipe execution.

The InTime flow configuration and recipe execution are outlined below. 

```tcl
# Configure InTime Flow settings 
# -> Type 'flow properties' in Tcl console to shows all the available flow property to configure
flow reset                 ; # Reset Intime internal flow 
flow restore_defaults      ; # Restore all flow property to default value
flow set run_target local  ; # Set to run strategies on local machine
flow set goal speed_tns    ; # Set goal type as speed_tns for timing optimization
flow set concurrent_runs 3 ; # Number of builds to run in parallel
flow set control_stop_when_goal_met true ; # Stop current recipe run when goal is met
flow set control_create_bitstreams false ; # Set to false to save compute time
```

- ```flow reset``` is used to reset the internal flow history. It is a recommended practice to always reset the internal flow history before running any recipe.
- ```flow set <property> <value>``` is the command to configure InTime flow settings. For example, ```setting flow set control_stop_when_goal```_met to true enables InTime to stop the current recipe when the goal is met. Otherwise, InTime allows the recipe to continue running even after the goal is met.
- Setting ```flow set control_create_bitstreams``` to true enables bitstream files to be created for every revision. Note: This takes up more time to complete each strategy.

To start a recipe, use the command ```flow run_recipe <recipe_name>``` as shown below. If the recipe run completes, the ```flow run_recipe``` command returns 0, otherwise it returns 1.

```tcl
# Run the current recipe
if { [catch { flow run_recipe $current_recipe }] } {
    puts "ERROR: Recipe $current_recipe failed, continuing with the rest of the flow... ${::errorInfo}"
    set recipe_run_fail 1
    set return_code 1
}        
```

### C. Results verification

In this section, the script checks if any revision in this round meets the target goal. If yes, it stops, otherwise it continues to execute the subsequent recipes until all user-defined recipes are executed.

```tcl
 # Check if the end goal was met. Stop this script run if goal met
set job_id [flow get local_job_id]
if { $flow_continue && !$recipe_run_fail } {
    puts "INFO: Checking results in $current_recipe recipe run \(job $job_id \) "
    results clear
    results add job $job_id
    set best_revision_name [lindex [results summary best -list] 0]
    catch { strategy unset_active }
    catch { strategy set_active $best_revision_name $job_id }
    set best_revision_tns    [ strategy results -field "TNS" ]
    set best_revision_wslack [ strategy results -field "Worst Slack" ]
    puts "INFO: -> Best result in job \($job_id\) is $best_revision_name revision with TNS = $best_revision_tns and Worst Slack = $best_revision_wslack "
    if { [is_job_met_criteria $job_id "" 0 "speed_tns" $end_tns_goal] } {
        puts "INFO: -> Goal met! .. exiting optimization"
        set flow_continue 0
        set goal_met 1
    }
}
```

### D. Export Strategies into Tcl Scripts
This section shows how to export strategy settings for each strategy into a Tcl script. 

```tcl
# Export strategies settings in tcl for success revisions
results clear 
catch { strategy unset_active }
set count 0
foreach id $jobs_ran {
    results add job $id
    set stratname_list_success [results summary success -list]
    set best_revname_per_job [lindex [results summary best -list] 0]
    foreach stratname $stratname_list_success {
        strategy set_active $stratname $id
        strategy export "$export_settings_tcl_dir/job${id}_${stratname}.tcl" -script_tcl
        catch { strategy unset_active }
    }
```

The command ```strategy export <export_tcl_name> -script_tcl``` is used to export settings for the current strategy into a Tcl script file. In this example, the script only exports strategies that compiled successfully. It uses the command ```results summary success -list``` to obtain a list of such strategies. You must always set the “active strategy” using the command ```strategy set_active <strategy_name> <job_id>``` before running the ```strategy export <export_tcl_name> -script_tcl``` command.

### E. Results Summary
When the recipe runs are done, the results will be inside the output directory. 

Under the output directory, you should see pass or fail file. If the end goal is met, you should able to see pass file in the output directory. Otherwise, you should see a fail file instead. 

The best_<job_id>_<strategy_name>.tcl script is an  Tcl script which reproduces the best timing result among the generated strategies. Meanwhile, the folder export_strategies_tcl contains the exported strategy Tcl scripts of all the other strategies that are compiled successfully. (Note that the output directory is cleaned up whenever this example script is executed. Please back up this folder if necessary.)

```tcl
# Export best strategy in tcl 
catch { strategy unset_active }
set best_job [ lindex $best_revname_n_job 0]
set best_revname [ lindex $best_revname_n_job 1]
strategy set_active $best_revname $best_job
strategy export "$result_dir/best_job${best_job}_${best_revname}.tcl" -script_tcl
catch { strategy unset_active }
```
This section will print a summary of the results you selected. To select all the relevant results using their job IDs: ```results add job <job_id>``` , then return  revisions that compiled successfully via ```results summary success``` command.

```tcl
# Export summary of results in summary_result.rpt
foreach id $jobs_ran {
    results add job $id
}

set summary_result [results summary success]
if { [catch { open $summary_result_rpt w } fh] } {
    puts "ERROR: Couldn't open file: $fh"
    set return_code 1
} else {
    puts $fh "$summary_result"
    catch { close $fh }
}
results clear
```
