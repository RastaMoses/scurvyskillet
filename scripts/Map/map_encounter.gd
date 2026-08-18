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

var encounter
var encounter_obj
var encounter_type

func randomize_encounter():
	var rand = random.randi_range(0,possible_encounters.size()-1)
	set_encounter(possible_encounters[rand])

func set_encounter(encounter_scene):
	encounter = encounter_scene
	encounter_type = encounter.encounter_type
	update_ui()

func end_encounter():
	event_manager.encounter_end()
	map.set_available_encounters()
	
func activate_encounter():
	event_manager.encounter_start()
	load_encounter(encounter)
	
func load_encounter(data):
	encounter = data
	encounter_type = data.encounter_type
	encounter_obj = encounter.instantiate()
	add_child(encounter_obj)
	encounter_obj.start()

func toggle_button(value):
	button.disabled = !value
	update_ui()
	
func update_ui():
	pass

func _on_button_pressed() -> void:
	activate_encounter()
