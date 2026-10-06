class_name Map
extends Node
#PARAMS
@export var encounter_nodes: Array[MapEncounter]
@export var map_difficulty:int
#CACHED COMPS
@onready var map_bg = $BG
@onready var map_loader = get_parent()
@onready var ship = $PlayerShip
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")

#STATE
var current_encounter:MapEncounter

func _ready() -> void:
	for i in encounter_nodes:
		i.map = self
		i.player_ship = ship
	event_manager.large_view_toggled.connect(toggle_large_view)

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

func toggle_large_view(value):
	if value:
		toggle_disabled_buttons(!value)
	else:
		set_available_encounters()

func toggle_disabled_buttons(value):
	for i in encounter_nodes:
		i.toggle_button(value)
