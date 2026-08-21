extends Control

@onready var description_text = $description/text
@onready var description_title = $description/title
@onready var bg_island = $BGLand
@onready var bg_water = $BGWater
@onready var player_inventory = get_node("/root/game/Player/Inventory")

@export var choices: Array[Node]

func start():
	choices = $Choices.get_children()
	for i in choices:
		i.decision_encounter = self
		i.start()
	player_inventory.ui.update_position(true)

func toggle_bg(bg_type:String):
	match bg_type:
		"water":
			bg_water.visible = true
			bg_island.visible = false
		"island":
			bg_water.visible = false
			bg_island.visible = true

func end():
	get_parent().end_encounter()
	queue_free()

func load_new_encounter(encounter):
	get_parent().load_encounter(encounter)
