extends Node
#STATE
@export_group("Leftovers")
@export var leftovers_bone:Resource

#CACHED COMPS
@onready var player_inventory = get_tree().get_first_node_in_group("player")
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
@onready var item_pool = get_tree().get_first_node_in_group("ingredient_pool")
#STATE
var active_dish_abilties:Array
var current_dish
#SIGNALS


func on_ingredient_destroyed_from_dish(card):
	for i in active_dish_abilties:
		
		if i[1] == card:
			active_dish_abilties.erase(i)
		#inventory abilities recheck
	check_rainbow_cake()

func on_encounter_end():
	#spoilable
	var spoiled_cards:Array
	for i in player_inventory.current_ingredients:
		if i.stats.abilities.has("spoilable") and !spoiled_cards.has(i):
			if i.stats.abilities.has("grapes"):
				player_inventory.add_ingredient(item_pool.get_ingredient_by_name("Red Wine"))
			if i.stats.abilities.has("fresh_milk"):
				player_inventory.add_ingredient(item_pool.get_ingredient_by_name("Yoghurt"))
			player_inventory.remove_ingredient(i)
			spoiled_cards.append(i)
			
	

func on_dish_complete():
	#reset all dish specific states
	active_dish_abilties.clear()

func on_challenge_start(dish):
	current_dish = dish

func on_challenge_end():
	active_dish_abilties.clear()

func on_dice_roll(card):
	pass

func on_die_roll(card):
	pass

func on_ingredient_add_to_dish(card): #before adding own stats to dish
	
	if card.stats.abilities.has("dessert"):
		active_dish_abilties.append(["dessert", card])
	
	#Seasoning
	if card.stats.abilities.has("seasoning"):
		active_dish_abilties.append(["seasoning", card])
	#Leftovers
	#Bone Leftovers
	if card.stats.abilities.has("leftover_bone"):
		player_inventory.add_ingredient(leftovers_bone)
	
	check_rainbow_cake()

func on_try_add_ingredient_any_inventory(card):
	var can_add = true
	if card.stats.abilities.has("undroppable"):
		can_add = false
	return can_add

func on_try_add_to_dish(card):
	for i in active_dish_abilties:
		if i[0] == "dessert":
			return false
	for i in active_dish_abilties:
		if i[0] == "seasoning" and i[1].stats.name == card.stats.name:
			return false
	if card.stats.abilities.has("starter") and current_dish.current_ingredients.size() > 0:
		return false
	
	return true


func check_rainbow_cake():
	if current_dish.sweet > 0 and current_dish.spicy > 0 and current_dish.hearty > 0 and current_dish.fresh > 0:
		for i in player_inventory.current_ingredients:
				if i.stats.abilities.has("rainbow_cake"):
					var already_active = false
					for j in active_dish_abilties: #check if card already has active bonus
						if j[0] == ("rainbow_cake") and j[1] == i:
							#card already active effect
							already_active = true
					if !already_active:
						i.stats.nutrition += 5
						active_dish_abilties.append(["rainbow_cake", i])
	else:
		for i in player_inventory.current_ingredients:
				if i.stats.abilities.has("rainbow_cake"):
					var already_active = false
					for j in active_dish_abilties: #check if card already has active bonus
						if j[0] == ("rainbow_cake") and j[1] == i:
							#card already active effect
							already_active = true
					if already_active:
						i.stats.nutrition -= 5
						active_dish_abilties.erase(["rainbow_cake", i])

func check_ability_flavour_conditions():
	if current_dish.sweet > 0 and current_dish.spicy > 0 and current_dish.hearty > 0 and current_dish.fresh > 0:
		for i in player_inventory.current_ingredients:
				if i.stats.abilities.has("rainbow_cake"):
					var already_active = false
					for j in active_dish_abilties: #check if card already has active bonus
						if j[0] == ("rainbow_cake") and j[1] == i:
							#card already active effect
							already_active = true
					if !already_active:
						i.stats.nutrition += 5
						active_dish_abilties.append(["rainbow_cake", i])
	else:
		for i in player_inventory.current_ingredients:
				if i.stats.abilities.has("rainbow_cake"):
					var already_active = false
					for j in active_dish_abilties: #check if card already has active bonus
						if j[0] == ("rainbow_cake") and j[1] == i:
							#card already active effect
							already_active = true
					if already_active:
						i.stats.nutrition -= 5
						active_dish_abilties.erase(["rainbow_cake", i])
