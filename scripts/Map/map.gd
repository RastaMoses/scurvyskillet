extends Node
#PARAMS
@export var encounter_nodes: Array[Node]
@export var map_difficulty:int
#CACHED COMPS
@onready var map_bg = $Sprite2D

#STATE
var player_location:int = 0

func populate_map():
	var temp = 0
	for i in encounter_nodes:
		i.encounter_index = temp
		if (i != null):
			i.randomize_encounter()
		temp += 1

func set_available_encounters():
	for i in encounter_nodes.size():
		if i != null:
			encounter_nodes[i].toggle_button(false)
	if encounter_nodes[player_location].destinations.size() != 0: 
		for active_node in encounter_nodes[player_location].destinations:
			#activate nodes the player can access
			encounter_nodes[active_node].toggle_button(true)
	else:
		#if this is last or first node on map
		pass

func update_player_location(value):
	player_location = value

func toggle_map_visible(value):
	map_bg.visible = value
	for i in encounter_nodes:
		if i != encounter_nodes[player_location]:
			i.visible = value
