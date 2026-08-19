extends Node

#PARAMS
@export_group("Values")
@export var current_money:int
@export var current_morale:int
var current_ingredients: Array[Node]
@export var starting_ingredients: Array[PackedScene]

#CACHED COMPS
@onready var ui = $InventoryUI

#STATE

func _ready() -> void:
	for i in starting_ingredients:
		instantiate_ingredient(i)

func instantiate_ingredient(ingredient_scene):
	var ingredient_instance = ingredient_scene.instantiate()
	add_child(ingredient_instance)
	current_ingredients.push_front(ingredient_instance)
	ui.update_slots()

func destroy_ingredient(ingredient_instance):
	current_ingredients.erase(ingredient_instance)
	ui.update_slots()
	ingredient_instance.queue_free()

func remove_ingredient(ingredient_instance):
	current_ingredients.erase(ingredient_instance)
	ui.update_slots()

func add_ingredient(ingredient_instance):
	ingredient_instance.reparent(self)
	current_ingredients.push_front(ingredient_instance)
	ui.update_slots()

func add_ingredient_remove_use(ingredient_instance):
	if !ingredient_instance.unlimited_uses:
		ingredient_instance.uses -= 1
	add_ingredient(ingredient_instance)
	ui.update_slots()

func change_money(new_value):
	current_money = new_value
	ui.update_topbar()

func change_morale(new_value):
	current_morale = new_value
	ui.update_topbar()
