#place ports in M6 M7
#placing clk and reset in middle of HM in east side
#Applying NDR port width for CLK
#
set ports [get_ports *]
#placing output ports in west side in layer M7
set_block_pin_constraints -self -allowed_layers {M7} -pin_spacing 1 -sides {1} -corner_keepout_distance 4
place_pins -ports [get_ports * -filter "direction == out"]
set ports [remove_from_collection $ports [get_ports * -filter "direction == out"]]
#placing clock port in the middle of HM in east side in layer M7
set_block_pin_constraints -self -allowed_layers {M7} -pin_spacing 1 -sides {3} -corner_keepout_distance 4
place_pins -ports [get_ports * -filter "name=~*clk*"] -self
set ports [remove_from_collection $ports [get_ports * -filter "name=~*clk*"]]

#placing reset port in north side in layer M6
set_block_pin_constraints -self -allowed_layers {M6} -pin_spacing 1 -sides {2} -corner_keepout_distance 4
place_pins -ports [get_ports * -filter "name=~*rst*"] -self
set ports [remove_from_collection $ports [get_ports * -filter "name=~*rst*"]]

#placing input ports in north side in layer M6
set_block_pin_constraints -self -allowed_layers {M6} -pin_spacing 1 -sides {2} -corner_keepout_distance 4
place_pins -ports [get_ports * -filter "name=~ *y1* || name=~*kjj* || name=~*kji* || name =~ *y2*"] -self
set ports [remove_from_collection $ports [get_ports * -filter "name=~ *y1* || name=~*kjj* || name=~*kji* || name =~ *y2*"]]

#placing output ports in east side in layer M7
set_block_pin_constraints -self -allowed_layers {M7} -pin_spacing 1 -sides {3} -corner_keepout_distance 4
place_pins -ports [get_ports $ports] -self

#setting the ports in alternate layer to form checkerboard pattern (M5 and M7)
set count 1
foreach_in_collection a [get_ports $a] { 
	if {[expr $count%2] == 1} {
		gui_change_layer -object [get_ports $a] -layer [get_layers M5]
	}
	set count [expr $count + 1]
} 
set count 1
foreach_in_collection a [get_ports -filter "name=~ *y1* || name=~*kjj* || name=~*kji* || name =~ *y2*"] { 
	if {[expr $count%2] == 1} {
		gui_change_layer -object [get_ports $a] -layer [get_layers M4]
	}
	set count [expr $count + 1]
}

set count 1
foreach_in_collection a [get_ports * -filter "direction==out"] { 
	if {[expr $count%2] == 1} {
		gui_change_layer -object [get_ports $a] -layer [get_layers M5]
	}
	set count [expr $count + 1]
}

place_pins -ports  [get_ports *] -legalize

