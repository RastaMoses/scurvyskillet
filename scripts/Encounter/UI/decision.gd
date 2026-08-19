extends Control

@onready var description_text = $description/text
@onready var description_title = $description/title

@export var choices: Array[Node]
var encounter_type = "decision"

func start():
	for i in choices:
		i.start()

func end():
	get_parent().end_encounter()
	queue_free()

func load_new_encounter(encounter):
	get_parent().load_encounter(encounter)
