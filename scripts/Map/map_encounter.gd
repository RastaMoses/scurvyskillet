extends Node

#PARAMS
@export var possible_encounters:Array[PackedScene]
@export var destinations: Array[int]
@export_enum("shop","decision","challenge","boss","none") var type:String
@export_enum("water","island") var bg_type:String
@export var icons:Array[Texture]

#CACHED COMPS
@onready var visuals = $Visuals
@onready var button = $Visuals/Button
@onready var icon = $Visuals/Icon
@onready var bg_water = $Visuals/BG/Water
@onready var bg_island = $Visuals/BG/Island
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
@onready var random = RandomNumberGenerator.new()
@onready var map
@onready var docking_points = $ShipDockingPoints.get_children()
var player_ship
#STATE
var encounter_index:int
var encounter
var encounter_obj

func randomize_encounter():
	var rand = random.randi_range(0,possible_encounters.size()-1)
	
	set_encounter(possible_encounters[rand])

func set_encounter(encounter_scene):
	encounter = encounter_scene
	#visuals
	match type:
		"shop":
			icon.texture = icons[0]
		"decision":
			icon.texture = icons[1]
		"challenge":
			icon.texture = icons[2]
		"boss":
			icon.texture = icons[3]
		"none":
			icon.texture = null
	match bg_type:
		"water":
			bg_water.visible = true
			bg_island.visible = false
		"island":
			bg_water.visible = false
			bg_island.visible = true

func end_encounter():
	type = "none"
	event_manager.encounter_end()
	map.toggle_map_visible(true)
	map.set_available_encounters()
	toggle_button(false)
	show_button(true)
	encounter_obj.queue_free()
	player_ship.toggle_ship_visible(true)
	
func activate_encounter():
	event_manager.encounter_start()
	load_encounter(encounter)
	map.toggle_map_visible(false)
	
func load_encounter(data):
	encounter = data
	if encounter_obj != null:
		encounter_obj.queue_free()
	encounter_obj = encounter.instantiate()
	add_child(encounter_obj)
	if type == "decision":
		encounter_obj.toggle_bg(bg_type)
	set_encounter(encounter_obj)
	encounter_obj.global_position = Vector2.ZERO
	encounter_obj.start()
	show_button(false)
	player_ship.toggle_ship_visible(false)

func toggle_button(value):
	button.disabled = !value

func show_button(value):
	button.visible = value

func move_ship():
	var rand_dock = docking_points[random.randi_range(0, docking_points.size()-1)]
	player_ship.start_moving(rand_dock, encounter_index)

func toggle_visuals(value):
	visuals.visible = value

func _on_button_pressed() -> void:
	
	toggle_button(false)
	move_ship()
	await player_ship.ship_arrived
	activate_encounter()
