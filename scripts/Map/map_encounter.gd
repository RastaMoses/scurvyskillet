extends Node

#PARAMS
@export var possible_encounters:Array[PackedScene]
@export var destinations: Array[int]
@export var type:GlobalEnums.EncounterType
@export var bg_type:GlobalEnums.EncounterTerrain
@export var icons:Array[Texture]

#CACHED COMPS
@onready var visuals = $Visuals
@onready var button = $Visuals/Button
@onready var icon = $Visuals/Icon
@onready var bg_ocean = $Visuals/BG/Water
@onready var bg_island = $Visuals/BG/Island
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
@onready var ability_manager = get_tree().get_first_node_in_group("ability_manager")
@onready var random = RandomNumberGenerator.new()
@onready var map
@onready var docking_points = $ShipDockingPoints.get_children()
var player_ship
#STATE
var encounter_index:int
var encounter:PackedScene
var encounter_obj:Node

func randomize_encounter():
	var rand = random.randi_range(0,possible_encounters.size()-1)
	
	set_encounter(possible_encounters[rand])

func set_encounter(encounter_scene):
	encounter = encounter_scene
	#visuals
	match type:
		GlobalEnums.EncounterType.SHOP:
			icon.texture = icons[0]
		GlobalEnums.EncounterType.DECISION:
			icon.texture = icons[1]
		GlobalEnums.EncounterType.CHALLENGE:
			icon.texture = icons[2]
		GlobalEnums.EncounterType.BOSS:
			icon.texture = icons[3]
		GlobalEnums.EncounterType.NONE:
			icon.texture = null
	match bg_type:
		GlobalEnums.EncounterTerrain.OCEAN:
			bg_ocean.visible = true
			bg_island.visible = false
		GlobalEnums.EncounterTerrain.ISLAND:
			bg_ocean.visible = false
			bg_island.visible = true

func end_encounter():
	type = GlobalEnums.EncounterType.NONE
	event_manager.encounter_end()
	map.toggle_map_visible(true)
	map.set_available_encounters()
	toggle_button(false)
	show_button(true)
	encounter_obj.queue_free()
	player_ship.toggle_ship_visible(true)
	ability_manager.on_encounter_end()
	
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
	set_encounter(encounter)
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
