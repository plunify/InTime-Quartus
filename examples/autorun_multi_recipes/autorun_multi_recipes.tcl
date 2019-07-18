#----------------------------------------------------------------------
# Script      : autorun_multi_recipes.tcl
# Description : Auto run multiple Intime Recipes with user-define order
#----------------------------------------------------------------------

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
} else {
    set recipes_list [list "intime_default"]
}

# Define end goal
set end_tns_goal 0
set end_wns_goal "*" ; #Don't Care

# Define tns goal for each recipe run
set recipe_target_result_tns(hot_start) "0"
set recipe_target_result_tns(intime_default) "0"
set recipe_target_result_tns(deep_dive) "0"
set recipe_target_result_tns(auto_placement) "0"
set recipe_target_result_tns(seeded_effort_level_exploration) "0"

# Define runs_per_round for each recipe run
set recipe_target_runs_p_round(hot_start) 50
set recipe_target_runs_p_round(intime_default) 10
set recipe_target_runs_p_round(deep_dive) 10
set recipe_target_runs_p_round(seeded_effort_level_exploration) 10
set recipe_target_runs_p_round(auto_placement) 10

# Define number of rounds for each recipe run
set recipe_target_rounds(hot_start) 1
set recipe_target_rounds(intime_default) 3
set recipe_target_rounds(deep_dive) 1
set recipe_target_rounds(seeded_effort_level_exploration) 2
set recipe_target_rounds(auto_placement) 1

# Configure InTime Flow settings 
# -> Type 'flow properties' in Tcl console to shows all the available flow property to configure
flow reset                 ; # Reset Intime internal flow 
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
        
        puts "\[RECIPE\]:  Running $current_recipe (con_runs = [flow get concurrent_runs], strategies = [flow get runs_per_round])"
        # Run the current recipe
        if { [catch { flow run_recipe $current_recipe }] } {
            logError "Recipe $current_recipe failed, continuing with the rest of the flow... ${::errorInfo}"
            set recipe_run_fail 1
        }
        lappend jobs_ran [flow get local_job_id]
    }

    # Terminate this script run if user stop it 
    set is_user_stop [flow get control_stop_by_user]
    if { [info exists is_user_stop] && [string equal "$is_user_stop" "true"] } {
        puts "User stop requested after recipe, terminating recipe..."
        set flow_continue 0
        break
    }

    # Check if the end goal was met. Stop this script run if goal met
    set job_id [flow get local_job_id]
    if { $flow_continue && !$recipe_run_fail } {
        puts "Checking results in $current_recipe recipe run \(job $job_id \) "
        results clear
        results add job $job_id
        set best_revision_name [lindex [results summary best -list] 0]
        catch { strategy unset_active }
        catch { strategy set_active $best_revision_name $job_id }
        set best_revision_tns    [ strategy results -field "TNS" ]
        set best_revision_wslack [ strategy results -field "Worst Slack" ]
        puts "-> Best result in job \($job_id\) is $best_revision_name revision with TNS = $best_revision_tns and Worst Slack = $best_revision_wslack "
        if { [is_job_met_criteria $job_id "" 0 "speed_tns" $end_tns_goal] } {
            puts "-> Goal met! .. exiting optimization"
            set flow_continue 0
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

# print summary
results clear
foreach job_id $jobs_ran {
    results add job $job_id
}
results summary success
results clear

# restore important variables
puts "Restoring original flow properties."
flow set parent_revision_name $original_parent_revision
flow set parent_revision_job_id $original_parent_job_id
flow set runs_per_round $original_runs_per_round
flow set rounds $original_rounds
puts "End of hands-free optimization"
