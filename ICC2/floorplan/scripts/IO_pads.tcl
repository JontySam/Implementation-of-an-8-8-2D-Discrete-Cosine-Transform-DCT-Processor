
set BYPASS_CONSTRAINTS 0
set no_io_power_EW 2
set no_core_power_EW 2
set no_io_power_NS 2
set no_core_power_NS 2

set no_io_ground_EW 2
set no_core_ground_EW 2
set no_io_ground_NS 2
set no_core_ground_NS 2

set input_ports [sort_collection -dictionary [filter_collection [get_ports] "direction=~in"] name]
remove_from_collection $input_ports clk
set output_ports [sort_collection -dictionary [filter_collection [get_ports] "direction=~out"] name]
#adding scan chain input and output ports 
#lappend test_si $input_ports
#lappend test_so $output_ports

set side 0
set order_side_1 [expr {2 + ($no_io_power_EW + $no_core_power_EW)/2 + ($no_io_ground_EW + $no_core_ground_EW)/2}]
set order_side_2 [expr {2 + ($no_io_power_NS + $no_core_power_NS)/2 + ($no_io_ground_NS + $no_core_ground_NS)/2}]
set order_side_3 [expr {2 + ($no_io_power_EW + $no_core_power_EW)/2 + ($no_io_ground_EW + $no_core_ground_EW)/2}]
set order_side_4 [expr {2 + ($no_io_power_NS + $no_core_power_NS)/2 + ($no_io_ground_EW + $no_core_ground_EW)/2}]

foreach_in_collection port $input_ports {
  set port_name [get_object_name $port] 
  puts $port_name 
   disconnect_net [get_nets -of [all_connected ${port_name}]] $port
  if {[expr {($side % 4) == 0}]} {
    create_cell PDCDG_W_${port_name} PDCDG_H
    create_net -tie_high ${port_name}_en
    connect_pins -driver $port [get_pins PDCDG_W_${port_name}/PAD]
    if {[get_attribute [get_net $port_name] net_type] == "power" || [get_attribute [get_net $port_name] net_type] == "ground"} {
     connect_pg_net -net  $port_name [get_pins PDCDG_W_${port_name}/PAD]	
    } else { 	
    connect_net $port_name [get_pins PDCDG_W_${port_name}/C]
    } 	
    connect_net ${port_name}_en [get_pins PDCDG_W_${port_name}/IE]
    create_net -tie_high ${port_name}_oen
    connect_net ${port_name}_oen [get_pins PDCDG_W_${port_name}/OEN]

 if {!$BYPASS_CONSTRAINTS} {

  }
     incr order_side_1
       }  elseif {[expr {($side % 4) == 1}]} {
    create_cell PDCDG_N_${port_name} PDCDG_V
    create_net -tie_high ${port_name}_en
    connect_pins -driver $port [get_pins PDCDG_N_${port_name}/PAD]
    if {[get_attribute [get_net $port_name] net_type] == "power" || [get_attribute [get_net $port_name] net_type] == "ground"} {
     connect_pg_net -net  $port_name [get_pins PDCDG_N_${port_name}/PAD]	
    } else { 	
    connect_net $port_name [get_pins PDCDG_N_${port_name}/C]
    } 	
    connect_net ${port_name}_en [get_pins PDCDG_N_${port_name}/IE]
    create_net -tie_high ${port_name}_oen
    connect_net ${port_name}_oen [get_pins PDCDG_N_${port_name}/OEN]

 if {!$BYPASS_CONSTRAINTS} {

   }
      incr order_side_2
        } elseif {[expr {($side % 4) == 2}]} {
    create_cell PDCDG_E_${port_name} PDCDG_H
    create_net -tie_high ${port_name}_en
    connect_pins -driver $port [get_pins PDCDG_E_${port_name}/PAD]
    if {[get_attribute [get_net $port_name] net_type] == "power" || [get_attribute [get_net $port_name] net_type] == "ground"} {
     connect_pg_net -net  $port_name [get_pins PDCDG_E_${port_name}/PAD]	
    } else { 	
    connect_net $port_name [get_pins PDCDG_E_${port_name}/C]
    } 	
    connect_net ${port_name}_en [get_pins PDCDG_E_${port_name}/IE]
    create_net -tie_high ${port_name}_oen
    connect_net ${port_name}_oen [get_pins PDCDG_E_${port_name}/OEN]
     if {!$BYPASS_CONSTRAINTS} {

    }
    incr order_side_3
  } else {
    create_cell PDCDG_S_${port_name} PDCDG_V
    create_net -tie_high ${port_name}_en
    connect_pins -driver $port [get_pins PDCDG_S_${port_name}/PAD]
    if {[get_attribute [get_net $port_name] net_type] == "power" || [get_attribute [get_net $port_name] net_type] == "ground"} {
     connect_pg_net -net  $port_name [get_pins PDCDG_S_${port_name}/PAD]	
    } else { 	
    connect_net $port_name [get_pins PDCDG_S_${port_name}/C]
    } 	
    connect_net ${port_name}_en [get_pins PDCDG_S_${port_name}/IE]
    create_net -tie_high ${port_name}_oen
    connect_net ${port_name}_oen [get_pins PDCDG_S_${port_name}/OEN]

    if {!$BYPASS_CONSTRAINTS} {

     }
     incr order_side_4
    }
         
}         

set side 0
foreach_in_collection port $output_ports {
  set port_name [get_object_name $port]
  set_attribute $port direction out

   disconnect_net [get_nets -of [all_connected ${port_name}]] $port 
  if {[expr {($side % 4) == 0}]} {
    create_cell PDCDG_W_${port_name} PDCDG_H
    create_net -tie_low ${port_name}_en
    create_net ${port_name}_padio
    connect_net ${port_name}_padio [get_port $port_name ]
    connect_net ${port_name}_padio [get_pins PDCDG_W_${port_name}/PAD]
    connect_net $port_name [get_pins PDCDG_W_${port_name}/I]
    connect_net ${port_name}_en [get_pins PDCDG_W_${port_name}/IE]
    connect_net ${port_name}_en [get_pins PDCDG_W_${port_name}/OEN]

    if {!$BYPASS_CONSTRAINTS} {

    }
    incr order_side_1
  } elseif {[expr {($side % 4) == 1}]} {
    create_cell PDCDG_N_${port_name} PDCDG_V
    create_net -tie_low ${port_name}_en
    create_net ${port_name}_padio
    connect_net ${port_name}_padio [get_port $port_name] 
    connect_net ${port_name}_padio [get_pins PDCDG_N_${port_name}/PAD]
    connect_net $port_name [get_pins PDCDG_N_${port_name}/I]
    connect_net ${port_name}_en [get_pins PDCDG_N_${port_name}/IE]
    connect_net ${port_name}_en [get_pins PDCDG_N_${port_name}/OEN]

    if {!$BYPASS_CONSTRAINTS} {

    }
    incr order_side_2
  } elseif {[expr {($side % 4) == 2}]} {
    create_cell PDCDG_E_${port_name} PDCDG_H
    create_net -tie_low ${port_name}_en
    create_net ${port_name}_padio
    connect_net ${port_name}_padio [get_port $port_name] 
    connect_net ${port_name}_padio [get_pins PDCDG_E_${port_name}/PAD]
    connect_net $port_name [get_pins PDCDG_E_${port_name}/I]
    connect_net ${port_name}_en [get_pins PDCDG_E_${port_name}/IE]
    connect_net ${port_name}_en [get_pins PDCDG_E_${port_name}/OEN]

    if {!$BYPASS_CONSTRAINTS} {

    }
    incr order_side_3
  } else {
    create_cell PDCDG_S_${port_name} PDCDG_V
    create_net -tie_low ${port_name}_en
    create_net ${port_name}_padio
    connect_net ${port_name}_padio [get_port $port_name] 
    connect_net ${port_name}_padio [get_pins PDCDG_S_${port_name}/PAD]
    connect_net $port_name [get_pins PDCDG_S_${port_name}/I]
    connect_net ${port_name}_en [get_pins PDCDG_S_${port_name}/IE]
    connect_net ${port_name}_en [get_pins PDCDG_S_${port_name}/OEN]

    if {!$BYPASS_CONSTRAINTS} {

    }
    incr order_side_4
  }

  incr side
}
set power_order_side_1 2
set power_order_side_2 2
set power_order_side_3 2
set power_order_side_4 2

for {set i 0} {$i < $no_core_power_EW} {incr i} {
  
  if {$i < [expr {$no_core_power_EW / 2}]} {
    create_cell vdd_W_${i} PVDD1CDGM_H
    if {!$BYPASS_CONSTRAINTS} {

    }

    incr power_order_side_1

    create_cell vdd_E_${i} PVDD1CDGM_H
    if {!$BYPASS_CONSTRAINTS} {

    }

    incr power_order_side_3

  } else {
    create_cell vdd_W_${i} PVDD1CDGM_H
    if {!$BYPASS_CONSTRAINTS} {

    }

    incr order_side_1

    create_cell vdd_E_${i} PVDD1CDGM_H
    if {!$BYPASS_CONSTRAINTS} {

    }

    incr order_side_3
  }  
}

   
for {set i 0} {$i < $no_core_power_NS} {incr i} {
  
  if {$i < [expr {$no_core_power_NS / 2}]} {
    create_cell vdd_N_${i} PVDD1CDGM_V
    if {!$BYPASS_CONSTRAINTS} {

    }

    incr power_order_side_2

    create_cell vdd_S_${i} PVDD1CDGM_V
    if {!$BYPASS_CONSTRAINTS} {

    }

    incr power_order_side_4

  } else {
    create_cell vdd_N_${i} PVDD1CDGM_V
    if {!$BYPASS_CONSTRAINTS} {

    }

    incr order_side_2

    create_cell vdd_S_${i} PVDD1CDGM_V
    if {!$BYPASS_CONSTRAINTS} {

    }

    incr order_side_4
  }  
}

   
for {set i 0} {$i < $no_core_ground_EW} {incr i} {
  
  if {$i < [expr {$no_core_ground_EW / 2}]} {
    create_cell vss_W_${i} PVDD1CDGM_H
    if {!$BYPASS_CONSTRAINTS} {

    }

    incr power_order_side_1

    create_cell vss_E_${i} PVDD1CDGM_H
    if {!$BYPASS_CONSTRAINTS} {

    }

    incr power_order_side_3
  } else {
    create_cell vss_W_${i} PVDD1CDGM_H
    if {!$BYPASS_CONSTRAINTS} {

    }

    incr order_side_1

    create_cell vss_E_${i} PVDD1CDGM_H
    if {!$BYPASS_CONSTRAINTS} {

    }

    incr order_side_3
  }  
}
   
 
for {set i 0} {$i < $no_core_ground_NS} {incr i} {
  
  if {$i < [expr {$no_core_ground_NS / 2}]} {
    create_cell vss_N_${i} PVDD1CDGM_V
    if {!$BYPASS_CONSTRAINTS} {

    }

    incr power_order_side_2

    create_cell vss_S_${i} PVDD1CDGM_V
    if {!$BYPASS_CONSTRAINTS} {

    }

    incr power_order_side_4
  } else {
    create_cell vss_N_${i} PVDD1CDGM_V
    if {!$BYPASS_CONSTRAINTS} {
    }

    incr order_side_2

    create_cell vss_S_${i} PVDD1CDGM_V
    if {!$BYPASS_CONSTRAINTS} {
    }

    incr order_side_4
  }  
}


             
set south_cells [get_cells *_S_*]
set north_cells [get_cells *_N_*]
set east_cells [get_cells *_E_*]
set west_cells [get_cells *_W_*]

#### setting the orientation for each side pad cells ####
set_attribute -objects [get_lib_cells -of [get_cells *_W_*]] -name reference_orientation -value R90
set_attribute -objects [get_lib_cells -of [get_cells *_E_*]] -name reference_orientation -value R90
set_attribute -objects [get_lib_cells -of [get_cells *_N_*]] -name reference_orientation -value R0
set_attribute -objects [get_lib_cells -of [get_cells *_S_*]] -name reference_orientation -value R0
### creating the IO ring #### 
create_io_ring -name io_ring2
add_to_io_guide io_ring2.bottom [get_cells $south_cells ]
add_to_io_guide io_ring2.top [get_cells $north_cells]
add_to_io_guide io_ring2.left [get_cells $west_cells]
add_to_io_guide io_ring2.right [get_cells $east_cells]
### placing the IO pads #### 
place_io

#### creating and placing the corner cells #### 
create_cell {cornerll cornerlr cornerul cornerur} PCORNER
create_io_corner_cell -cell cornerll {io_ring2.left io_ring2.bottom}
create_io_corner_cell -cell cornerlr {io_ring2.bottom io_ring2.right}
create_io_corner_cell -cell cornerur {io_ring2.right io_ring2.top}
create_io_corner_cell -cell cornerul {io_ring2.top io_ring2.left}

### placing the ports #####
place_pins -self
