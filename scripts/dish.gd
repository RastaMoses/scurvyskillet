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
#STATE
var current_ingredients: Array[Node]

func add_ingredient(ingredient):
	current_ingredients.append(ingredient)

func remove_ingredient(ingredient):
	current_ingredients.erase(ingredient)

func roll_dish():
	for ingredient in current_ingredients:
		nutrition += ingredient.ingredient_stats.nutrition
		for die in ingredient.ingredient_stats.sweet:
			pass
		
