extends Node
#PARAMS
@export var encounter_nodes: Array[Node]
@export var map_difficulty:int
#CACHED COMPS
@onready var map_bg = $BG
@onready var map_loader = get_parent()
@onready var ship = $PlayerShip

#STATE

func _ready() -> void:
	encounter_nodes = $Encounter.get_children()
	for i in encounter_nodes:
		i.map = self
		i.player_ship = ship

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
	if encounter_nodes[ship.current_pos].destinations.size() != 0: 
		for active_node in encounter_nodes[ship.current_pos].destinations:
			#activate nodes the player can access
			encounter_nodes[active_node].toggle_button(true)
	else:
		#if this is last node generate new map
		map_loader.load_map(map_loader.pick_random_map(map_difficulty + 1))

func toggle_map_visible(value):
	map_bg.visible = value
	for i in encounter_nodes:
		if i != encounter_nodes[ship.current_pos]:
			i.toggle_visuals(value)
			i.visible = value
		else:
			i.toggle_visuals(value)
