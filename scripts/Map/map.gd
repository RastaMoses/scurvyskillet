extends Node
#PARAMS
@export var encounter_nodes: Array[Node]
@export var map_difficulty:int
#CACHED COMPS

#STATE
var player_location:int

func populate_map():
	for i in encounter_nodes:
		i.randomize_encounter()

func set_available_encounters():
	for i in encounter_nodes.size():
		encounter_nodes[i].toggle_button(false)
	if encounter_nodes[player_location].possible_destinations.size() != 0: 
		for active_node in encounter_nodes[player_location].possible_destinations:
			#activate nodes the player can access
			active_node.toggle_button(true)
	else:
		#if this is last node on map
		pass
