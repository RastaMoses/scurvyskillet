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
	add_ingredient(ingredient_instance)

func destroy_ingredient(ingredient_instance):
	current_ingredients.erase(ingredient_instance)
	ui.update_slots()
	if ingredient_instance.get_parent() == self:
		ingredient_instance.queue_free()

func remove_ingredient(ingredient_instance):
	change_ingredient_uses(ingredient_instance, -1)
	ui.update_slots()

func add_ingredient(ingredient_instance):
	#Check if ingredient is already in inventory
	var duplicates:Array[Node]
	for i in current_ingredients:
		if i.get_ingredient_name() == ingredient_instance.get_ingredient_name():
			duplicates.append(i)
	#find duplicate with less than 4 uses and assign more uses until the added card has no more
	if duplicates.size() > 0:
		for i in duplicates:
			while i.uses < 4 and ingredient_instance.uses != 0:
				change_ingredient_uses(i, 1)
				change_ingredient_uses(ingredient_instance, -1)
			if ingredient_instance.uses == 0 or ingredient_instance == null:
					ui.update_slots()
					return
	ingredient_instance.reparent(self)
	current_ingredients.push_front(ingredient_instance)
	ui.update_slots()

func change_ingredient_uses(ingredient_instance,amount):
	if ingredient_instance.unlimited_uses:
		return
	ingredient_instance.uses += amount
	if ingredient_instance.uses <= 0:
		destroy_ingredient(ingredient_instance)

func change_money(new_value):
	current_money = new_value
	ui.update_topbar()

func change_morale(new_value):
	current_morale = new_value
	ui.update_topbar()
