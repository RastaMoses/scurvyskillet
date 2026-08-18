extends Node

#PARAMS
@export_group("Values")
@export var current_money:int
@export var current_morale:int
@export var current_ingredients: Array[Node]

#CACHED COMPS

#STATE

func _ready() -> void:
	var on_start_item = load("res://scenes/ingredients/card_sample.tscn")
	instantiate_ingredient(on_start_item)
	on_start_item = load("res://scenes/ingredients/card_sample2.tscn")
	instantiate_ingredient(on_start_item)
	on_start_item = load("res://scenes/ingredients/card_sample2.tscn")
	instantiate_ingredient(on_start_item)

func instantiate_ingredient(ingredient_scene):
	var ingredient_instance = ingredient_scene.instantiate()
	add_child(ingredient_instance)
	current_ingredients.push_front(ingredient_instance)

func destroy_ingredient(ingredient_instance):
	current_ingredients.erase(ingredient_instance)
	ingredient_instance.queue_free()

func remove_ingredient(ingredient_instance):
	current_ingredients.erase(ingredient_instance)

func add_ingredient(ingredient_instance):
	ingredient_instance.reparent(self)
	current_ingredients.push_front(ingredient_instance)
	$InventoryCooking.update_slots()

func add_ingredient_remove_use(ingredient_instance):
	ingredient_instance.uses -= 1
	add_ingredient(ingredient_instance)

func change_money(new_value):
	current_money = new_value

func change_morale(new_value):
	current_morale = new_value
