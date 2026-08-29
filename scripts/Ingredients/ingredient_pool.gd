extends Node

var all_ingredients:Array[Ingredient]
@onready var random = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dir_path := "res://resources/ingredients/in_game/"
	var paths : PackedStringArray = ResourceLoader.list_directory(dir_path)
	if paths == null: printerr("Could not get ingredient folder")
	for path in paths:
		var ingr:Ingredient= ResourceLoader.load(dir_path + path) as Ingredient
		if ingr:
			all_ingredients.append(ingr)

func get_random_ingredient(and_req:bool, tag:Array[GlobalEnums.Tags] = [], ability:Array[Ability] = [],rarity:Array[GlobalEnums.Rarity] = []) -> Ingredient:
	var possible_ingredients:Array[Ingredient]
	for i in all_ingredients:
		var can_add:bool
		#if all req
		if and_req:
			#check if rarity is given
			can_add = true
			if !rarity.is_empty():
				if !rarity.has(i.rarity):
					can_add = false
			#check if a tag is in the ingredients tags
			if !tag.is_empty():
				var has_tag = false
				for j in i.tags:
					if tag.has(j):
						has_tag = true
				if !has_tag:
					can_add = false
			if !ability.is_empty():
				#check abilities
				var has_ability = false
				for j in i.abilities:
					if ability.has(j):
						has_ability = true
				if !has_ability:
					can_add = false
			
		else:
			#any must suffice
			#check if rarity is given
			can_add = false
			if !rarity.is_empty():
				if rarity.has(i.rarity):
					can_add = true
			#check if a tag is in the ingredients tags
			if !tag.is_empty():
				var has_tag = false
				for j in i.tags:
					if tag.has(j):
						has_tag = true
				if has_tag:
					can_add = true
			if !ability.is_empty():
				#check abilities
				var has_ability = false
				for j in i.abilities:
					if ability.has(j):
						has_ability = true
				if has_ability:
					can_add = true
		if tag.is_empty() and rarity.is_empty() and ability.is_empty():
			can_add = true
		if can_add:
			possible_ingredients.append(i)
	if possible_ingredients.size() != 0:
		var rand_ingr:Ingredient = possible_ingredients[random.randi_range(0, possible_ingredients.size()-1)]
		
		return rand_ingr
	else:
		printerr("No ingredient fitting the reqs was found")
		return(null)
	
func get_ingredient_by_name(name:String) -> Ingredient:
	for i in all_ingredients:
		if i.name == name:
			return i
	printerr("Could not find ingredient with this name")
	return null
