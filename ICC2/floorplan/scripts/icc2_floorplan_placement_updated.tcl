set COMMENTED_OUT [list ]

#There is file called app_option_list.tcl which have all application options and default values which guides tool at different stages
#This app options drives the engines algorithm to guide the optimization in particular way 
#Ex place_opt app option guides the placement optimization 
#Here we are going with default set of the application options but design to design the optimization strategy varies, so fill free to have looks on options and experments your final projects design for different optimization## 
#set DESIGN_NAME stop_watch

set DESIGN_NAME dct_8_2d
set place_use_topo_mode 0 ; 

#Setup 

 puts "Hostnme : [info hostname]"

 # Directory housekeeping
  foreach dir "outputs reports" {
        if {![file isdirectory $dir]} {
        file mkdir $dir
        }
        }
redirect -file /dev/null {set start_time [clock seconds]}

################################
# ## set variables used to prepate Milkyway Lib
# set GDS_OUT_LAYER_MAP           
set MW_TECH_FILE               /home/vlsilab2/TSMCHOME/Executable_Package/Collaterals/Tech/APR/N16ADFP_APR_ICC2/N16ADFP_APR_ICC2_11M.10a.tf 
set MAX_TLUPLUS_FILE           /home/vlsilab2/TSMCHOME/Executable_Package/Collaterals/Tech/RC/N16ADFP_STARRC/N16ADFP_STARRC_worst.nxtgrd 
set MIN_TLUPLUS_FILE           /home/vlsilab2/TSMCHOME/Executable_Package/Collaterals/Tech/RC/N16ADFP_STARRC/N16ADFP_STARRC_best.nxtgrd 
# set TLUPLUS_MAP_FILE            
set MW_POWER_NET                "VDD"
set MW_GROUND_NET               "VSS"

###############################
## ICC Tool Veriables

 set auto_restore_mw_cel_lib_setup true
 set mw_logic1_net $MW_POWER_NET
 set mw_logic0_net $MW_GROUND_NET
 set legalize_auto_x_keepout_margin 0
 set legalize_auto_y_keepout_margin 0
 set no_row_gap 1
 set_app_options -as_user_default -name time.remove_clock_reconvergence_pessimism -value true
 set_host_options -max_cores 16
 set_app_options  -name  lib.setting.compress_design_lib -value true
#### Check the design presence ###
if {[file exists ${DESIGN_NAME}_LIB/]} { sh rm -rf ${DESIGN_NAME}_LIB/ }
 file delete -force $DESIGN_NAME

### setting ref_lib variable to all ndms #### 
set ref_lib [eval [list exec echo] [glob ndms/*.ndm]]
#set ref_lib [eval [list exec echo] [glob ndms/N16ADFP_StdCell]]
### creating the design lib ##### 
create_lib $DESIGN_NAME -technology $MW_TECH_FILE -ref_libs $ref_lib 


if {[file exists ./inputs/${DESIGN_NAME}_syn.vg]} {
  puts "==>INFORMATION: Reading the synthesized gate-level netlist." 
   read_verilog -top full_chip_$DESIGN_NAME  ./inputs/${DESIGN_NAME}_syn.vg 
}  else {
  puts "==>FATAL: ${DESIGN_NAME}_syn.vg synthesized gate-level netlist does not exist in ./inputs/ area. Exiting..."
}

current_block full_chip_${DESIGN_NAME}
link_block
### setting ref_lib variable to all ndms ####  
 
# Read IO, Loading and timing constraints 
  if {[file exists ./inputs/${DESIGN_NAME}_syn.sdc]} {
  puts "==>INFORMATION: Reading the synthesized-design constraints file"
  read_sdc ./inputs/${DESIGN_NAME}_syn.sdc
  } else {
	 puts "==>FATAL: Synthesized-Design Constraints file does not exists... Exiting..."
 	}
### sanity checks #### 
check_timing                            > ./reports/${DESIGN_NAME}.check_timing.rpt
#report_clock                            > ./reports/${DESIGN_NAME}.clock.rpt
#report_clock -skew                      >> ./reports/${DESIGN_NAME}.clock.rpt

connect_pg_net -automatic
check_mv_design -pg_pin -pg_netlist

set_isolate_ports -type buffer [filter_collection [all_outputs] "direction=~out"]
set_auto_disable_drc_nets -constant false -scan false -on_clock_network false
set_voltage 0.8
set_ideal_network [all_fanout -flat -clock_tree]

### setting case analysis on the test paths #### 
set_case_analysis 0 test_se

#### saving design before floorplanning ##### 
save_lib -as ${DESIGN_NAME}_import_design

#### creating floorplan , select core width, offset, side length as per your design size ##### 

initialize_floorplan -boundary { {0 0} {0 155} {165 160} {165 0} } -control_type die -core_offset {1 1 1 1}  -core_utilization 0.85 -honor_pad_limit  -use_site_row
### Creating the IO pads #### 
#source scripts/IO_pads.tcl
place_pins -self
save_block -as cp_before_power_planning
### power planing #######  
source scripts/power_planning.tcl
######### edit input scan def to include input pads for scanchain inputs and outputs #############################
#set si_pad [get_object_name [get_cells -regexp .*test_si.*]]
#set so_pad [get_object_name [get_cells -regexp .*test_so.*]]

#set so_fline "/+ STOP.*/c\+ STOP "
#append so_fline "" $so_pad " DIN ;"
#append so_fline "" $so_pad " I ;"
#set si_fline "/+ START.*/c\+ START "
#append si_fline "" $si_pad " DOUT"
#append si_fline "" $si_pad " C"

#exec sed -i $so_fline inputs/$DESIGN_NAME\_syn.scan.def
#exec sed -i $si_fline inputs/$DESIGN_NAME\_syn.scan.def

###### scan def sourcing after pad cell insertion ##### 
if {[file exists ./inputs/${DESIGN_NAME}_syn.scan.def]} {
	puts "==>INFORMATION: Reading SCANDEF information of the synthesized design."
	read_def ./inputs/${DESIGN_NAME}_syn.scan.def
}  else {
         puts "==>FATAL: Synthesized-Design Constraints file does not exists... Exiting..."
        }

### Path group creation based on the path #### 
group_path -name inputs -from [all_inputs]
group_path -name output -to [all_outputs]
group_path -name comb -from [remove_from_collection [all_inputs] [all_outputs]] -to [all_outputs]
group_path -name reg2reg -from [all_registers -clock_pins] -to [all_registers -data_pins]

### connect the pg nets  and checking any power pin related drc #### 
connect_pg_net -automatic
check_mv_design -pg_pin -pg_netlist
	
### setting the routing direction ### 
#set VERTICAL_ROUTING_LAYER_LIST "M1 M3 M5 M7 M9"
set VERTICAL_ROUTING_LAYER_LIST "M2 M4 M6 M8 M10"
set HORIZONTAL_ROUTING_LAYER_LIST "M1 M3 M5 M7 M9 M11"
        set_attribute -object [get_layers $VERTICAL_ROUTING_LAYER_LIST] -name routing_direction -value vertical -quiet

# set HORIZONTAL_ROUTING_LAYER_LIST "M2 M4 M6 M8 MRDL"
        set_attribute -object [get_layers $HORIZONTAL_ROUTING_LAYER_LIST] -name routing_direction -value horizontal -quiet

### set dont touch on io pads ### 
# set_dont_touch [filter_collection [get_cells *] "is_io==true"]
### min routing layer M2 
# set_ignored_layers  -min_routing_layer M2

### input transition and load ### 
remove_driving_cell [remove_from_collection [all_inputs] [all_outputs]]
set_input_transition 0.2 [remove_from_collection [all_inputs] [all_outputs]]
#set_load 2500 [all_outputs]

# set_app_option -name file.tlup.max_preservation_size -value 250
 read_parasitic_tech -tlup $MAX_TLUPLUS_FILE -name tlu_max
 read_parasitic_tech -tlup $MIN_TLUPLUS_FILE  -name tlu_min
 set_parasitic_parameters -early_spec tlu_min -late_spec tlu_max

### Coarse placement round one ###
remove_buffer_trees -hfs_fanout_threshold 1 -all
#### coarse placement app options to control the congestion #### feel free to play with options based on your design criticality #### 
set plan.place.auto_max_density true
set plan.place.default_keepout true
set place.coarse.auto_density_control true  
set place.coarse.congestion_driven_max_util 0.93
set place.coarse.pin_density_aware true 
####
#### coarse placement timing control options 
set place.coarse.auto_timing_control true
set place.coarse.balance_registers true
set place.coarse.congestion_layer_aware true
#####

create_placement -timing_driven -congestion -congestion_effort high
connect_pg_net 
### performing global routing and creating congestion map ### 
route_global -congestion_map_only true

save_block -as cp_done
##### Analysing the IR drop  ######
#set_virtual_pad -net VSS -coordinate {168.065 169.632}
#set_virtual_pad -net VSS -coordinate {168.065 170.552}
#set_virtual_pad -net VSS -coordinate {178.046 169.632}
#set_virtual_pad -net VSS -coordinate {189.046 123.552}
#analyze_power_plan -nets {VDD VSS} -pad_references "VDD:VDD_NS VDD:VDD_EW VSS:VSS_EW VSS:VSS_NS" -analyze_power

###### reporting ###########
report_power > ./reports/${DESIGN_NAME}_power.rpt
report_timing >  ./reports/${DESIGN_NAME}.timing.rpt
report_congestion > reports/${DESIGN_NAME}_congestion_cp1.rpt
report_design > reports/${DESIGN_NAME}_design_cp1.rpt
report_clocks > reports/${DESIGN_NAME}_clock_cp1.rpt
report_qor > reports/${DESIGN_NAME}_qor_cp1.rpt
######################### 

##### writing output files######
#write_verilog -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells} -hierarchy all outputs/counter_cr.PostFloorplan.v
write_verilog -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells} -hierarchy all outputs/$DESIGN_NAME\.PostFloorplan.v
write_sdc -nosplit -output outputs/${DESIGN_NAME}.sdc 
################################

if {$place_use_topo_mode == 1} {
	remove_cell  [get_flat_cell * -filter "design_type==lib_cell"]
	#write_def -include {blockages specialnets vias cut_metal} -include_physical_status placed ./outputs/counter_cr.PostFloorplan.DEF
	#write_def -exclude {cells} outputs/counter_cr.PostFloorplan_full.DEF
        write_def -include {blockages specialnets vias cut_metal} -include_physical_status placed ./outputs/$DESIGN_NAME\.PostFloorplan.DEF
	write_def -exclude {cells} outputs/$DESIGN_NAME\.PostFloorplan_full.DEF
} else {

	## Setting the logical DRC for the design ###  
	set_max_transition 5.0 [current_design] 
	set_max_capacitance 5.0 [current_design] 

	#### place opt optimization app options 
	set place_opt.initial_place.effort high
	set place_opt.flow.enable_multibit_banking true 
	set place.coarse.tns_driven_placement true 
	set place_opt.initial_place.buffering_aware true
	set place_opt.initial_drc.global_route_based true  
	#############################################

	### optimizing the logical drc #####
	 place_opt -from initial_drc -to initial_opto
	### Further incremental timing and legalization of the cells #### 
	 place_opt -from final_place
	##### reporting #############
	report_qor > reports/${DESIGN_NAME}_qor_final_place.rpt
	report_power > ./reports/${DESIGN_NAME}_power_final_place.rpt
	report_timing >  ./reports/${DESIGN_NAME}.timing_final_place.rpt
	report_congestion > reports/${DESIGN_NAME}_congestion_final_place.rpt 
        report_utilization > reports/${DESIGN_NAME}_util.rpt
	#############3
	
	#### dont delete saved db #### we will continue from here in lab 10 #####	
	save_block -as placement_done 
}


set elapsed_time [expr { ([clock seconds] - $start_time) / 60.0} ]
puts [format "##### Done. Runtime: %.2f mins, Memory Used: %.1f GB #####" $elapsed_time [expr [mem] / 1000000.0]]

