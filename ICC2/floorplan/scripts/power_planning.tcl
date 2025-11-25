create_pg_ring_pattern R2  -vertical_layer M10 -horizontal_layer M11 -horizontal_width 2.5 -vertical_width 5 -side_spacing { {side: 1 2 3 4} {spacing: 2 } }
 
lappend pg_mesh_strategies ring2

set_pg_strategy ring2 -core -pattern  "{name: R2} {nets: {VDD VSS}} {offset:{15 15}}" -extension "{nets: {VDD VSS}} {side: 1 2 3 4} {stop: pad_rings}"
compile_pg -strategies ring2

set PG_grid {
    {M1 horizontal 0.36   0.064 0.0 }
    {M2 vertical 0.256   0.032 0.0 }
    {M3 horizontal 1.024   0.032 0.0 }  
    {M4 vertical 1.28   0.040 0.0 }    
    {M5 horizontal 1.28   0.040 0.0 }  
    {M6 vertical 1.28   0.062 0.0 }    
    {M7 horizontal 5.12   0.062 0.0 }  
    {M8 vertical 8.064   0.062 0.0 }    
    {M9 horizontal 8.064   0.450 0.0 }  
    {M10 vertical 57.6   0.450 0.0 }    
    {M11 horizontal 57.6   0.450 0.0 }  
}


set supply_nets {
{VDD power}
{VSS ground}
}

connect_pg_net -automatic
remove_routes -net_types power -lib_cell_pin_connect
remove_routes -net_types ground -lib_cell_pin_connect
remove_routes -net_types power -stripe
remove_routes -net_types ground -stripe

#created by Duke Daffin

#### connect ports to nets. #####
connect_pg_net -net VDD [get_port VDD]
connect_pg_net -net VSS [get_port VSS]
connect_pg_net -net VDD [get_pins -hierarchical */VDD]
connect_pg_net -net VSS [get_pins -hierarchical */VSS]
###### to dissable via connection during compile pg

set_app_options -name plan.pgroute.disable_via_creation -value true
###### to create rail ######

create_pg_std_cell_conn_pattern rail_pattern -layers M1 -rail_width [lindex $PG_grid 0 3]
set_pg_strategy M1_rails -core -pattern {{name: rail_pattern} nets: VDD VSS}
compile_pg -strategies M1_rails

###### define pg mesh for m4 t0 m9 layers (only core region) ######
create_pg_mesh_pattern M4toM9 -layers {{{vertical_layer: M4} {spacing: 0.20} {pitch:5.12} {width:0.040} {offset:1.04}} {{vertical_layer: M6} {spacing: 0.178} {pitch:25.6} {width:0.062} {offset:1.04}} {{horizontal_layer: M5} {spacing: 0.20} {pitch:5.12} {width:0.040} {offset:1.04}} {{horizontal_layer: M7} {spacing: 0.178} {pitch:25.6} {width:0.062} {offset:1.04}} {{vertical_layer: M8 } {width: 0.6} {pitch: 40.32} {spacing: 0.442} {offset: 1.134}} {{horizontal_layer: M9} {width: 0.6} {pitch: 40.32} {spacing: interleaving} {offset: 0.0}}}

set_pg_strategy pg_mesh_M4_2_M9 -core -pattern {{name: M4toM9 } {nets: VDD VSS }}

compile_pg -strategies pg_mesh_M4_2_M9 -ignore_drc

############ define pg for M10 M11. ##################

create_pg_mesh_pattern M10toM11 -layers {{{vertical_layer: M10} {width: 2.4} {pitch: 90} {spacing: interleaving} {offset: 0.0} {track_alignment : track}} {{horizontal_layer: M11} {width: 2.4} {pitch: 90} {spacing: interleaving} {offset: 0.0} {track_alignment : track}}}
set_pg_strategy pg_mesh_M10_2_M11 -core -pattern {{name: M10toM11 } {nets: VDD VSS }} -extension {{stop: outermost_ring}}

compile_pg -strategies pg_mesh_M10_2_M11 -ignore_drc


###### checks after pg mesh #####
check_pg_drc

##### M1 to M4 vias ########
set_pg_via_master_rule M4_M1 -contact_code {VIA12_1cut_W1C VIA23_1cut VIA34_1cut}
create_pg_vias -nets {VDD VSS} -from_layers M4 -to_layers M1 -via_masters M4_M1 -allow_parallel_objects -within_bbox [get_attribute [current_block] bbox]
check_pg_drc
check_pg_missing_vias


#M5_M4#33

set_pg_via_master_rule M5_M4 -contact_code {VIA45_1cut}
create_pg_vias -nets {VDD VSS} -from_layers M5 -to_layers M4 -via_masters M5_M4 -allow_parallel_objects -within_bbox [get_attribute [current_block] bbox]
check_pg_drc
check_pg_missing_vias

# M6_M5

set_pg_via_master_rule M6_M5 -contact_code {VIA56_1cut_W2A}
create_pg_vias -nets {VDD VSS} -from_layers M6 -to_layers M5 -via_masters M6_M5 -allow_parallel_objects -within_bbox [get_attribute [current_block] bbox]
check_pg_drc
check_pg_missing_vias

#M7_M6

set_pg_via_master_rule M7_M6 -contact_code {VIA67_1cut_W2}
create_pg_vias -nets {VDD VSS} -from_layers M7 -to_layers M6 -via_masters M7_M6 -allow_parallel_objects -within_bbox [get_attribute [current_block] bbox]
check_pg_drc
check_pg_missing_vias

# M8_M7

set_pg_via_master_rule M8_M7 -contact_code {VIA78_1cut}
create_pg_vias -nets {VDD VSS} -from_layers M8 -to_layers M7 -via_masters M8_M7 -allow_parallel_objects -within_bbox [get_attribute [current_block] bbox]
check_pg_drc
check_pg_missing_vias

#M9_M8

set_pg_via_master_rule M9_M8 -contact_code {VIA89_1cut_VV}
create_pg_vias -nets {VDD VSS} -from_layers M9 -to_layers M8 -via_masters M9_M8 -allow_parallel_objects -within_bbox [get_attribute [current_block] bbox]
check_pg_drc
check_pg_missing_vias

#M9_10

set_pg_via_master_rule M10_M9 -contact_code {VIA910_1cut}
create_pg_vias -nets {VDD VSS} -from_layers M10 -to_layers M9 -via_masters M10_M9 -allow_parallel_objects -within_bbox [get_attribute [current_block] bbox]
check_pg_drc
check_pg_missing_vias

#M10_M11

set_pg_via_master_rule M11_M10 -contact_code {VIA1011_1cut_VV}
create_pg_vias -nets {VDD VSS} -from_layers M11 -to_layers M10 -via_masters M11_M10 -allow_parallel_objects -within_bbox [get_attribute [current_block] bbox]
check_pg_drc
check_pg_missing_vias
