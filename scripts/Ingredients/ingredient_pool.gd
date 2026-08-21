extends Node

var all_ingredients:Array[Resource]
@onready var random = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dir := DirAccess.open("res://scenes/ingredients/")
	if dir == null: printerr("Could not get ingredient folder")
	for i in dir.get_files():
		var ingr = load(dir.get_current_dir() + "/" + i)
		all_ingredients.append(ingr)

func get_random_ingredient(and_req:bool, tag:Array[String] = [], ability:Array[String] = [],rarity:Array[int] = []) -> Resource:
	var possible_ingredients:Array[Resource]
	for i in all_ingredients:
		var can_add:bool
		#if all req
		if and_req:
			#check if rarity is given
			can_add = true
			if !rarity.has(i.rarity):
				can_add = false
			#check if a tag is in the ingredients tags
			var has_tag = false
			for j in i.tags:
				if tag.has(j):
					has_tag = true
			if !has_tag:
				can_add = false
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
			if rarity.has(i.rarity):
				can_add = true
			#check if a tag is in the ingredients tags
			var has_tag = false
			for j in i.tags:
				if tag.has(j):
					has_tag = true
			if has_tag:
				can_add = true
			#check abilities
			var has_ability = false
			for j in i.abilities:
				if ability.has(j):
					has_ability = true
			if has_ability:
				can_add = true
		if tag == [] and rarity == [] and ability == []:
			can_add = true
		if can_add:
			possible_ingredients.append(i)
	if possible_ingredients.size() != 0:
		var rand_ingr = possible_ingredients[random.randi_range(0, possible_ingredients.size()-1)]
		
		return rand_ingr
	else:
		return(null)
