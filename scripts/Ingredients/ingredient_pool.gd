extends Node

var all_ingredients:Array[Resource]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dir := DirAccess.open("res://scenes/ingredients/")
	if dir == null: printerr("Could not get ingredient folder")
	for i in dir.get_files():
		var ingr = load(dir.get_current_dir() + "/" + i)
		all_ingredients.append(ingr)

func get_random_ingredient(rarity:int, tag:String, ability:String, and_req:bool):
	var possible_ingredients:Array[Resource]
	for i in all_ingredients:
		if and_req:
			var can_add = false
		
		else:
			pass

func check_rarity(ingredient, req_rarity) -> bool:
	#check for rarity
	if ingredient.rarity == req_rarity:
		return true
	else:
		return false
