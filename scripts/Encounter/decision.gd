extends Control

@onready var description_text = $description/text
@onready var description_title = $description/title
@onready var player_inventory = get_node("/root/game/Player/Inventory")

@export var choices: Array[Node]

func start():
	choices = $Choices.get_children()
	for i in choices:
		i.decision_encounter = self
		i.start()
	player_inventory.ui.update_position(true)

func end():
	get_parent().end_encounter()
	queue_free()

func load_new_encounter(encounter):
	get_parent().load_encounter(encounter)
