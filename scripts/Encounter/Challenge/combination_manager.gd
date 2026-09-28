extends Node

#Params

#Comps
@onready var challenge = get_parent() 
@onready var item_pool = get_tree().get_first_node_in_group("ingredient_pool")

#State
var dish
var upgraded_dish
var all_combinations:Array[Combination]
var active_combinations:Array[Combination]

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
	active_combinations.append(get_combination_by_name(c_name))

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
#endregion

func start_combinations(new_dish):
	dish = new_dish
	check_combinations()
	activate_effects()

func check_combinations():

#region Stats
#Check for stats
	#Lacking
	if (dish.nutrition < 0
	or dish.sweet < 0
	or dish.spicy < 0
	or dish.hearty < 0
	or dish.fresh < 0):
		set_comb_active("Lacking")
	
	#Jam
	if (dish.sweet > dish.spicy
	and dish.sweet > dish.hearty
	and dish.sweet > dish.fresh
	and dish.get_tag_amount_in_inventory(GlobalEnums.Tags.FRUIT)):
		set_comb_active("Jam")
#endregion
#region Tags
#Check for tags
	
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
	var dish_countries:Array[GlobalEnums.Country]
	if dish.get_country_amount_in_inventory(GlobalEnums.Country.MEDITERRANEAN) > 0:
		dish_countries.append(GlobalEnums.Country.MEDITERRANEAN)
	if dish.get_country_amount_in_inventory(GlobalEnums.Country.NORDIC) > 0:
		dish_countries.append(GlobalEnums.Country.NORDIC)
	if dish.get_country_amount_in_inventory(GlobalEnums.Country.JUNGLE) > 0:
		dish_countries.append(GlobalEnums.Country.JUNGLE)
	if dish.get_country_amount_in_inventory(GlobalEnums.Country.ASIAN) > 0:
		dish_countries.append(GlobalEnums.Country.ASIAN)
	#Fusion Kitchen
	if dish_countries.size() >= 3:
		set_comb_active("Fusion Kitchen")
#endregion
#region Ingredients
#Check if certain ingredients are in the dish
	#Buttercob
	if (dish.count_ingredient_in_inventory(item_pool.get_ingredient_by_name("Corn")) > 0
	and dish.count_ingredient_in_inventory(item_pool.get_ingredient_by_name("Butter")) > 0):
		set_comb_active("Buttercob")

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

#region Effects
func activate_effects():
	upgraded_dish = dish.duplicate()
	#activate based on effect type (if has debuff come last)
	return
#region Buffs

#endregion
#region Debuffs

#endregion
#region Morale/Money

#endregion
#region Create

#endregion


#endregion
