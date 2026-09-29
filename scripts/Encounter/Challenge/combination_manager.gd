class_name CombinationManager
extends Node

#Params

#Comps
@onready var challenge = get_parent() 
@onready var item_pool = get_tree().get_first_node_in_group("ingredient_pool")
@onready var ability_manager:AbilityManager = get_tree().get_first_node_in_group("ability_manager")

#State
var dish:Dish
var upgraded_dish
var all_combinations:Array[Combination]
var active_combinations:Array[Combination]

var mult_flavours:Array[float] = [1.0,1.0,1.0,1.0,1.0]
var mult_nutrition:float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dir_path := "res://resources/combinations/"
	var paths : PackedStringArray = ResourceLoader.list_directory(dir_path)
	if paths == null: printerr("Could not get Combination folder")
	for path in paths:
		var ingr:Combination= ResourceLoader.load(dir_path + path) as Combination
		if ingr:
			all_combinations.append(ingr)

#region Helper
func set_comb_active(c_name):
	var combination = get_combination_by_name(c_name)
	if combination == null:
		return
	active_combinations.append(combination)

func get_combination_by_name(c_name) -> Combination:
	var comb:Combination
	for i in all_combinations:
		if i.name == c_name:
			comb = i
	if comb == null:
		printerr("Couldnt find the combination named: " + c_name)
		return null
	else:
		return comb

func get_combinations_with_relevant_ingr(rel_ingr) -> int:
	var count:int = 0
	for i in active_combinations:
		if i.relevant_ingredients.has(rel_ingr):
			count += 1
	return count
	
func order_active_combinations():
	#Sort the active combinations based on effec type and specific dependencies (addition before multiply)
	return
#endregion

func start_combinations(new_dish:Dish):
	dish = new_dish
	check_combinations()
	order_active_combinations()
	activate_effects()
	apply_multipliers()
#region Requirements
func check_combinations():

#Check if dish empty
	if dish.current_cards.size() == 0:
		set_comb_active("Admit Defeat")
		return
#region Stats
#Check for stats
	#Lacking
	if (dish.nutrition < 0
	or dish.flavours[GlobalEnums.Flavour.SWEET] < 0
	or dish.flavours[GlobalEnums.Flavour.SPICY] < 0
	or dish.flavours[GlobalEnums.Flavour.HEARTY] < 0
	or dish.flavours[GlobalEnums.Flavour.FRESH] < 0):
		set_comb_active("Lacking")
	
	#Jam
	if (dish.flavours[GlobalEnums.Flavour.SWEET] > dish.flavours[GlobalEnums.Flavour.SPICY]
	and dish.flavours[GlobalEnums.Flavour.SWEET] > dish.flavours[GlobalEnums.Flavour.HEARTY]
	and dish.flavours[GlobalEnums.Flavour.SWEET] > dish.flavours[GlobalEnums.Flavour.FRESH]
	and dish.get_all_cards_with_tag(GlobalEnums.Tags.FRUIT).size() >= 3):
		set_comb_active("Jam")
	
	#Scoville Hell
	if dish.flavours[GlobalEnums.Flavour.SPICY] > dish.flavours[GlobalEnums.Flavour.FRESH] + dish.flavours[GlobalEnums.Flavour.HEARTY] + dish.flavours[GlobalEnums.Flavour.SWEET]:
		set_comb_active("Scoville Hell")
	
#endregion
#region Tags
#Check for tags
	#Pure
	for tag in dish.get_tags_in_inventory():
		if dish.current_cards.size() == dish.get_all_cards_with_tag(tag).size():
			set_comb_active("Pure")
			break
	
	#Dry
	if (dish.get_all_cards_with_tag(GlobalEnums.Tags.DRINK).size() == 0
	and dish.get_all_cards_with_tag(GlobalEnums.Tags.OIL).size() == 0
	and dish.get_all_cards_with_tag(GlobalEnums.Tags.FERMENT).size() == 0
	and dish.get_all_cards_with_tag(GlobalEnums.Tags.FRUIT).size() == 0):
		set_comb_active("Dry")
	
	#Salmonella
	if (dish.can_cover_tags([GlobalEnums.Tags.MEAT, GlobalEnums.Tags.FISH, GlobalEnums.Tags.MONSTER])):
		set_comb_active("Salmonella")
	
	#Quishe
	if (dish.get_all_cards_with_tag(GlobalEnums.Tags.EGG).size() >= dish.current_cards.size()/2
	 and dish.current_cards.size() > 1):
		set_comb_active("Quishe")
	
	#Salad
	if (dish.current_cards.size() > 1
	and dish.get_cards_with_tags([GlobalEnums.Tags.FRUIT, GlobalEnums.Tags.VEGETABLE]).size() >= dish.current_cards.size()/2):
		set_comb_active("Salad")
	
	#Sandwich
	if (dish.can_cover_tags([GlobalEnums.Tags.PASTRY, GlobalEnums.Tags.PASTRY, GlobalEnums.Tags.VEGETABLE])
	and dish.get_cards_with_tags([GlobalEnums.Tags.FISH, GlobalEnums.Tags.MEAT]).size() >= 1):
		set_comb_active("Sandwich")
	
	#Smoothie
	if (dish.current_cards.size() > 1
	and dish.get_all_cards_with_tag(GlobalEnums.Tags.FRUIT).size() == dish.get_all_cards_with_tag(GlobalEnums.Tags.DRINK).size()):
		set_comb_active("Smoothie")
	
	#Parfait
	if (dish.can_cover_tags([GlobalEnums.Tags.GRAINS, GlobalEnums.Tags.DAIRY, GlobalEnums.Tags.FRUIT])):
		set_comb_active("Parfait")
	
	#Deep Fried
	var oil_amount = dish.get_all_cards_with_tag(GlobalEnums.Tags.OIL).size()
	if (oil_amount > dish.get_all_cards_with_tag(GlobalEnums.Tags.MEAT).size()
	and oil_amount > dish.get_all_cards_with_tag(GlobalEnums.Tags.FISH).size()
	and oil_amount > dish.get_all_cards_with_tag(GlobalEnums.Tags.MONSTER).size()
	and oil_amount > dish.get_all_cards_with_tag(GlobalEnums.Tags.FRUIT).size()
	and oil_amount > dish.get_all_cards_with_tag(GlobalEnums.Tags.VEGETABLE).size()
	and dish.get_cards_with_tags([GlobalEnums.Tags.MEAT,GlobalEnums.Tags.FISH, 
	GlobalEnums.Tags.MONSTER, GlobalEnums.Tags.FRUIT, GlobalEnums.Tags.VEGETABLE]).size() > 0):
		set_comb_active("Deep Fried")
	
	#Reinheitsgebot
	if (dish.can_cover_tags([GlobalEnums.Tags.GRAINS, GlobalEnums.Tags.FERMENT, GlobalEnums.Tags.DRINK])
	and dish.current_cards.size() <= 3):
		set_comb_active("Reinheitsgebot")
	
	#Overseasoned
	if dish.get_all_cards_with_tag(GlobalEnums.Tags.SPICE).size() >= 5:
		set_comb_active("Overseasoned")
#endregion
#region Rarity
#Check for Rarity
	var dish_rarities:Array[GlobalEnums.Rarity]
	if dish.get_rarity_amount_in_inventory(GlobalEnums.Rarity.COMMON) > 0:
		dish_rarities.append(GlobalEnums.Rarity.COMMON)
	if dish.get_rarity_amount_in_inventory(GlobalEnums.Rarity.UNCOMMON) > 0:
		dish_rarities.append(GlobalEnums.Rarity.UNCOMMON)
	if dish.get_rarity_amount_in_inventory(GlobalEnums.Rarity.RARE) > 0:
		dish_rarities.append(GlobalEnums.Rarity.RARE)
	if dish.get_rarity_amount_in_inventory(GlobalEnums.Rarity.LEGENDARY) > 0:
		dish_rarities.append(GlobalEnums.Rarity.LEGENDARY)
	
	#Fine Dining
	if (not dish_rarities.has(GlobalEnums.Rarity.COMMON)
	and not dish_rarities.has(GlobalEnums.Rarity.UNCOMMON)
	and dish.current_cards.size() > 0):
		set_comb_active("Fine Dining")
	
	#Cheap
	if (not dish_rarities.has(GlobalEnums.Rarity.UNCOMMON)
	and not dish_rarities.has(GlobalEnums.Rarity.RARE)
	and not dish_rarities.has(GlobalEnums.Rarity.LEGENDARY)
	and dish.current_cards.size() > 0):
		set_comb_active("Cheap")
#endregion
#region Countries
#check for countries
	#Get Dish Countries
	var dish_countries:Array[GlobalEnums.Country] = dish.get_countries_in_inventory()
	if dish.can_cover_countries(dish_countries) and dish_countries.size() >= 3:
		set_comb_active("Fusion Kitchen")
#endregion
#region Abilities
#3-Course Meal
	if (dish.can_cover_abilities([ability_manager.get_ability_by_name("Starter"), ability_manager.get_ability_by_name("Dessert")])
	and dish.current_cards.size() >= 3):
		set_comb_active("Fusion Kitchen")
#endregion
#region Ingredients
#Check if certain ingredients are in the dish
	#Buttercob
	if (dish.count_ingredient_in_inventory(item_pool.get_ingredient_by_name("Corn")) > 0
	and dish.count_ingredient_in_inventory(item_pool.get_ingredient_by_name("Butter")) > 0):
		set_comb_active("Buttercob")
	
	#Barely Cooked
	if (dish.get_unique_base_ingredients().size() == 1):
		set_comb_active("Barely Cooked")
	
	if (dish.count_ingredient_in_inventory(item_pool.get_ingredient_by_name("Dough")) > 0
	and dish.count_ingredient_in_inventory(item_pool.get_ingredient_by_name("Tomato")) > 0
	and dish.current_cards.size() >= 3):
		set_comb_active("Pizza")
	
	#Sushi
	if (dish.count_ingredient_in_inventory(item_pool.get_ingredient_by_name("Seaweed")) > 0
	and dish.count_ingredient_in_inventory(item_pool.get_ingredient_by_name("Rice")) > 0
	and dish.get_all_cards_with_tag(GlobalEnums.Tags.FISH).size() > 0):
		set_comb_active("Sushi")
	
	#Mayan Hot Cocoa
	if (dish.count_ingredient_in_inventory(item_pool.get_ingredient_by_name("Cacao")) > 0
	and dish.get_all_cards_with_tag(GlobalEnums.Tags.DRINK).size() > 0):
		set_comb_active("Mayan Hot Cocoa")
	
	#Chocolate
	if (dish.count_ingredient_in_inventory(item_pool.get_ingredient_by_name("Cacao")) > 0
	and dish.count_ingredient_in_inventory(item_pool.get_ingredient_by_name("Sugar")) > 0
	and dish.get_all_cards_with_tag(GlobalEnums.Tags.DAIRY).size() > 0):
		set_comb_active("Chocolate")
	
	#Rum
	if (dish.count_ingredient_in_inventory(item_pool.get_ingredient_by_name("Sugarcane")) > 0
	and dish.get_all_cards_with_tag(GlobalEnums.Tags.FERMENT).size() > 0):
		set_comb_active("Rum")
	
#Check if certain item orders are correct
	
	#Dolmades
	var wine_leaves_indexes = dish.get_indexes_of_ingredient(item_pool.get_ingredient_by_name("Wine Leaves"))
	var rice_indexes = dish.get_indexes_of_ingredient(item_pool.get_ingredient_by_name("Rice"))
	var dolmades_activates = false
	if wine_leaves_indexes.size() > 0 and rice_indexes.size() > 0:
		for wine_leaves in wine_leaves_indexes:
			for rice in rice_indexes:
				if wine_leaves == rice - 1:
					dolmades_activates = true
					break
		if dolmades_activates:
			set_comb_active("Dolmades")
	
	#Topping
	if (dish.current_cards.size() >= 2
	and dish.current_cards.back().committed_stats.tags.has(GlobalEnums.Tags.SPICE)):
		set_comb_active("Topping")
#endregion


#region Other Combinations
#check for other combinations HAS TO BE LAST TO BE CHECKED
	#Upset Stomache
	var dough = item_pool.get_ingredient_by_name("Dough")
	if (dish.count_ingredient_in_inventory(dough)
	and get_combinations_with_relevant_ingr(dough) == 0):
		set_comb_active("Upset Stomache")
	
	#check for slop (no other active combinations)
	if active_combinations.is_empty():
		set_comb_active("Slop")
	
	#Split Opinion
	if (active_combinations.has(get_combination_by_name("Pizza"))
	and dish.count_ingredient_in_inventory(item_pool.get_ingredient_by_name("Pineapple")) > 0):
		set_comb_active("Split Opinion")
	#endregion
#endregion
#region Effects
func activate_effects():
	upgraded_dish = dish.duplicate()
	#activate based on effect type (if has debuff come last)
	
	
	for combination in active_combinations:
		match combination.name:
			
		#region Buffs
			"Quishe":
				mult_nutrition += 2.0
			"3-Course Meal":
				mult_nutrition += 1.5
				for flav in mult_flavours:
					flav += 1.5
			"Buttercob":
				mult_nutrition += 1.25
			"Dolmades":
				mult_flavours[GlobalEnums.Flavour.FRESH] += 1.5
			"Fine Dining":
				mult_flavours[dish.get_greatest_flavour()] += 2.5
			
		#endregion
		#region Debuffs

		#endregion
		#region Player

		#endregion
		#region Create

		#endregion
		challenge.ui.add_combination_result_text(combination)
		challenge.ui.update_flavours(upgraded_dish)
		challenge.ui.update_nutrition(upgraded_dish.nutrition)

func apply_multipliers():
	upgraded_dish.flavours[GlobalEnums.Flavour.SPICY] = floori(float(upgraded_dish.flavours[GlobalEnums.Flavour.SPICY] * mult_flavours[GlobalEnums.Flavour.SPICY]))
	upgraded_dish.flavours[GlobalEnums.Flavour.SWEET] = floori(float(upgraded_dish.flavours[GlobalEnums.Flavour.SWEET] * mult_flavours[GlobalEnums.Flavour.SWEET]))
	upgraded_dish.flavours[GlobalEnums.Flavour.HEARTY] = floori(float(upgraded_dish.flavours[GlobalEnums.Flavour.HEARTY] * mult_flavours[GlobalEnums.Flavour.HEARTY]))
	upgraded_dish.flavours[GlobalEnums.Flavour.FRESH] = floori(float(upgraded_dish.flavours[GlobalEnums.Flavour.FRESH] * mult_flavours[GlobalEnums.Flavour.FRESH]))
	upgraded_dish.nutrition = floori(float(upgraded_dish.nutrition * mult_nutrition))

#endregion
