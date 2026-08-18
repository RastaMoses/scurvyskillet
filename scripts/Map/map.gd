extends Node
#PARAMS
@export var encounter_nodes: Array[Node]
@export var map_difficulty:int
#CACHED COMPS

#STATE
var player_location:int

func populate_map():
	for i in encounter_nodes:
		if (i != null):
			i.randomize_encounter()

func set_available_encounters():
	for i in encounter_nodes.size():
		if i != null:
			encounter_nodes[i].toggle_button(false)
	if encounter_nodes[player_location].destinations.size() != 0: 
		for active_node in encounter_nodes[player_location].destinations:
			#activate nodes the player can access
			active_node.toggle_button(true)
	else:
		#if this is last or first node on map
		pass
