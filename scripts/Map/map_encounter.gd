extends Node

#PARAMS
@export var possible_encounters:Array[PackedScene]
@export var destinations: Array[int]

#CACHED COMPS
@onready var button = $Button
@onready var event_manager = get_node("/root/root/EventManager")
@onready var random = RandomNumberGenerator.new()
@onready var map = get_parent()
#STATE
var encounter_index:int
var encounter
var encounter_obj

func randomize_encounter():
	var rand = random.randi_range(0,possible_encounters.size()-1)
	set_encounter(possible_encounters[rand])

func set_encounter(encounter_scene):
	encounter = encounter_scene
	update_ui()

func end_encounter():
	event_manager.encounter_end()
	map.toggle_map_visible(true)
	map.set_available_encounters()
	toggle_button(false)
	show_button(true)
	encounter_obj.queue_free()
	
func activate_encounter():
	event_manager.encounter_start()
	map.update_player_location(encounter_index)
	load_encounter(encounter)
	toggle_button(false)
	map.toggle_map_visible(false)
	
func load_encounter(data):
	encounter = data
	encounter_obj = encounter.instantiate()
	add_child(encounter_obj)
	encounter_obj.global_position = Vector2.ZERO
	encounter_obj.start()
	show_button(false)

func toggle_button(value):
	button.disabled = !value
	update_ui()

func show_button(value):
	button.visible = value

func update_ui():
	pass

func _on_button_pressed() -> void:
	activate_encounter()
	print("encounter activated")
