extends Node
#PARAMS
@export var nutrition:int
@export_subgroup("Flavour")
@export var sweet:int
@export var sour:int
@export var spicy:int
@export var hearty:int
@export var fresh:int

#CACHED COMPS
var random = RandomNumberGenerator.new()
@onready var inventory = get_node("/root/root/Player/Inventory")
#STATE
var current_ingredients: Array[Node]

func add_ingredient(ingredient):
	inventory.remove_ingredient(ingredient)
	current_ingredients.append(ingredient)
	ingredient.reparent(self)
	get_node("/root/root/EventManager").add_to_dish(ingredient)

func remove_ingredient(ingredient):
	current_ingredients.erase(ingredient)
func remove_all_ingredients():
	current_ingredients.clear()
	

func destroy_all_ingredients():
	for i in current_ingredients:
		i.queue_free()
	current_ingredients.clear()

func roll_dish():
	get_node("/root/EventManager").dish_complete(self)
	for ingredient in current_ingredients:
		nutrition += ingredient.ingredient_stats.nutrition
		var in_sweet = ingredient.ingredient_stats.sweet
		while in_sweet > 0:
			sweet += random.randi_range(1,6)
			in_sweet -= 1
		var in_sour = ingredient.ingredient_stats.sour
		while in_sour > 0:
			sour += random.randi_range(1,6)
			in_sour -= 1
		var in_spicy = ingredient.ingredient_stats.spicy
		while in_spicy > 0:
			spicy += random.randi_range(1,6)
			in_spicy -= 1
		var in_hearty = ingredient.ingredient_stats.hearty
		while in_hearty > 0:
			hearty += random.randi_range(1,6)
			in_hearty -= 1
		var in_fresh = ingredient.ingredient_stats.fresh
		while in_fresh > 0:
			fresh += random.randi_range(1,6)
			in_fresh -= 1
	get_parent().compare_dish(self)
