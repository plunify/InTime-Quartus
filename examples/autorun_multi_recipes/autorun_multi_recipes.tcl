#----------------------------------------------------------------------
# Script      : autorun_multi_recipes.tcl
# Description : auto run multiple Intime Recipes with user-define order
#               
# Return : 0 - script run ok , 1 - script run not_ok
#
# Usage : Eg 
#    1. Via Intime TCL concole
#       % source autorun_multi_recipes.tcl
#       Or
#       % source_with_args autorun_multi_recipes.tcl -output_dir <output_dir>
#
#    2. Via Command-line
#       % intime.sh -mode batch -project <proj> -s autorun_multi_recipes.tcl
#       Or 
#       % intime.sh -mode batch -project <proj> -s autorun_multi_recipes.tcl -tclargs "-output_dir <output_dir>"
#----------------------------------------------------------------------

package require cmdline

set return_code 0

set options { \
    { output_dir.arg    "results"    "Output directory.(Optional)" } 
}

if { [catch { ::cmdline::getoptions argv $options } inargs] } {
    puts "ERROR: Invalid input arguments, please try again.\n[::cmdline::usage $options]"
    set return_code 1
    return $return_code
}

array set opts $inargs

# Create & Clean up result directory
set result_dir $opts(output_dir)
set summary_result_rpt "$result_dir/summary_result.rpt"
set export_settings_tcl_dir "$result_dir/export_settings_tcls"
if { [file exists $result_dir] } {
    file delete -force -- $result_dir
    puts "INFO: Overwrited existing directory : $result_dir"
}

file mkdir $result_dir
file mkdir $export_settings_tcl_dir

# Back up important information
set original_parent_revision [flow get parent_revision_name]
set original_parent_job_id   [flow get parent_revision_job_id]
set original_runs_per_round  [flow get runs_per_round]
set original_rounds          [flow get rounds]


# Define order of recipes to execute. 
# -> Type 'flow recipes -supported' in Tcl console to show all available recipe's name
set current_toolchain [project info toolchain]
if { [string equal "$current_toolchain" "quartusii"] } {
    # Execution Order : hot_start > intime_default > deep_dive > seeded_effort_level_exploration
    set recipes_list [list "hot_start" "intime_default" "deep_dive" "seeded_effort_level_exploration" ]

} elseif { [string equal "$current_toolchain" "vivado"] } {
    set recipes_list [list "intime_default" "deep_dive" "vivado_explorer" "extra_opt_exploration"]

} else {
    set recipes_list [list "intime_default"]

}

# Define end goal
set end_tns_goal 0
set end_wns_goal "*" ; #Don't Care

# Define tns goal for each recipe run
set recipe_target_result_tns(hot_start) "-2500"
set recipe_target_result_tns(intime_default) "-1000"
set recipe_target_result_tns(deep_dive) "-500"
set recipe_target_result_tns(auto_placement) "0"
set recipe_target_result_tns(seeded_effort_level_exploration) "0"
set recipe_target_result_tns(vivado_explorer) "0"
set recipe_target_result_tns(extra_opt_exploration) "0"


# Define runs_per_round for each recipe run
set recipe_target_runs_p_round(hot_start) 50
set recipe_target_runs_p_round(intime_default) 10
set recipe_target_runs_p_round(deep_dive) 10
set recipe_target_runs_p_round(seeded_effort_level_exploration) 10
set recipe_target_runs_p_round(auto_placement) 10
set recipe_target_runs_p_round(vivado_explorer) 10
set recipe_target_runs_p_round(extra_opt_exploration) 10


# Define number of rounds for each recipe run
set recipe_target_rounds(hot_start) 1
set recipe_target_rounds(intime_default) 3
set recipe_target_rounds(deep_dive) 1
set recipe_target_rounds(seeded_effort_level_exploration) 2
set recipe_target_rounds(auto_placement) 1
set recipe_target_rounds(vivado_explorer) 1
set recipe_target_rounds(vivado_placement_exploration) 1
set recipe_target_rounds(extra_opt_exploration) 1

# Configure InTime Flow settings 
# -> Type 'flow properties' in Tcl console to shows all the available flow property to configure
flow reset                 ; # Reset Intime internal flow 
flow restore_defaults      ; # Restore all flow property to default value
flow set run_target local  ; # Set to run strategies on local machine
flow set goal speed_tns    ; # Set goal type as speed_tns for timing optimization
flow set concurrent_runs 3 ; # Number of builds to run in parallel
flow set control_stop_when_goal_met true ; # Stop current recipe run when goal is met
flow set control_create_bitstreams false ; # Set to false to save compute time

# ==============================================================
# DO NOT TOUCH THE CODES BELOW UNLESS YOU KNOW WHAT YOU ARE DOING
# ==============================================================

# Define variable
set flow_continue 1
set is_user_stop "true"
set job_id 0
set goal_met 0
set jobs_ran [list]

foreach current_recipe $recipes_list {

    set recipe_run_fail 0
    if { $flow_continue } {
        # Set round and runs per round for each recipe run
        flow set runs_per_round    "$recipe_target_runs_p_round($current_recipe)"
        flow set rounds            "$recipe_target_rounds($current_recipe)"
        # Set goal for each recipe run
        flow set goal_based_target "$recipe_target_result_tns($current_recipe)"

        set current_parent_revision_name [flow get parent_revision_name]
        set current_parent_revision_job_id [flow get parent_revision_job_id]
        
        puts "\[RECIPE\]:  Running $current_recipe (rounds = [flow get rounds], strategies = [flow get runs_per_round])"
        # Run the current recipe
        if { [catch { flow run_recipe $current_recipe }] } {
            puts "ERROR: Recipe $current_recipe failed, continuing with the rest of the flow... ${::errorInfo}"
            set recipe_run_fail 1
            set return_code 1
        }
        lappend jobs_ran [flow get local_job_id]
    }

    # Terminate this script run if user stop it 
    set is_user_stop [flow get control_stop_by_user]
    if { [info exists is_user_stop] && [string equal "$is_user_stop" "true"] } {
        puts "INFO: Received stop request from user, terminating recipe..."
        set flow_continue 0
        set return_code 1
        break
    }

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
        if { [is_job_met_criteria $job_id "" 0  "speed_tns" $end_tns_goal ] } {
            puts "INFO: -> Goal met! .. exiting optimization"
            set flow_continue 0
            set goal_met 1
        }
    }

    # Set parent revision for next recipe run
    if {$flow_continue} {
        if { [string compare $best_revision_name $current_parent_revision_name] == 0 } {
            puts "Recipe $current_recipe could not improve on its parent revision result"
            puts "Setting $current_parent_revision_name revision as parent revision for next recipe run"
            flow set parent_revision_name $current_parent_revision_name
            flow set parent_revision_job_id $current_parent_revision_job_id
        } else {
            flow set parent_revision_name $best_revision_name
            flow set parent_revision_job_id $job_id
        }
    }
}

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

    catch { strategy set_active $best_revname_per_job $id }
    if { $count == 0 } {
        set best_revname_n_job [list $id $best_revname_per_job]
        set best_revision_tns    [ strategy results -field "TNS" ]
        incr count
    } else {
        if {$best_revision_tns <= [ strategy results -field "TNS" ]} {
            set best_revision_tns    [ strategy results -field "TNS" ]
            set best_revname_n_job [list $id $best_revname_per_job]
        }
    }

    results clear
    catch { strategy unset_active }
}

# Export best strategy in tcl 
catch { strategy unset_active }
set best_job [ lindex $best_revname_n_job 0]
set best_revname [ lindex $best_revname_n_job 1]
strategy set_active $best_revname $best_job
strategy export "$result_dir/best_job${best_job}_${best_revname}.tcl" -script_tcl
catch { strategy unset_active }

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

# Create file named "pass" if found any revision met end_goal.
if {$goal_met} {
    puts "INFO: Goal met! Generating \"pass\" file into $result_dir "
    if { [catch { open "$result_dir/pass" w } fh] } {
        puts "ERROR: Couldn't open file: $fh"
        set return_code 1
    } else {
        catch { close $fh }
    }
} else {
    puts "INFO: Goal not met! Generating \"fail\" file into $result_dir "
    if { [catch { open "$result_dir/fail" w } fh] } {
        puts "ERROR: Couldn't open file: $fh"
        set return_code 1
    } else {
        catch { close $fh }
    }
}

# restore important variables
puts "Restoring original flow properties."
flow set parent_revision_name $original_parent_revision
flow set parent_revision_job_id $original_parent_job_id
flow set runs_per_round $original_runs_per_round
flow set rounds $original_rounds
puts "End of hands-free optimization"

return $return_code
