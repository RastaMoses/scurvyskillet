extends Node

#PARAMS

#CACHED COMPS
@onready var button = $Button
#STATE
var possible_destinations: Array[int]
var encounter
var encounter_obj
var encounter_type

func set_encounter(encounter_scene):
	encounter = encounter_scene
	encounter_type = encounter.encounter_type
	#visual updates

func toggle_button(value):
	button.disabled = !value
	#visual update

func activate_encounter():
	encounter_obj = encounter.instantiate()
	add_child(encounter_obj)
	#start encounter
	get_node("/root/root/EventManager").encounter_start()
	encounter_obj.start()
	

func _on_button_pressed() -> void:
	activate_encounter()
