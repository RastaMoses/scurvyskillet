extends Control

@onready var description_text = $description/text
@onready var description_title = $description/title
@onready var bg_island = $BGLand
@onready var bg_ocean = $BGWater
@onready var player_inventory = get_tree().get_first_node_in_group("player")

@export var terrain_type:GlobalEnums.EncounterTerrain
@export var choices: Array[Choices]

func start():
	for i in choices:
		i.decision_encounter = self
		i.start()

func toggle_bg():
	match terrain_type:
		GlobalEnums.EncounterTerrain.OCEAN:
			bg_ocean.visible = true
			bg_island.visible = false
		GlobalEnums.EncounterTerrain.ISLAND:
			bg_ocean.visible = false
			bg_island.visible = true

func end():
	get_parent().end_encounter()
	queue_free()

func load_new_encounter(encounter):
	get_parent().load_encounter(encounter)
