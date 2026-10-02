class_name CombinationManager
extends Node

#Params

#Comps
@onready var challenge = get_parent() 
@onready var item_pool = get_tree().get_first_node_in_group("ingredient_pool")
@onready var ability_manager:AbilityManager = get_tree().get_first_node_in_group("ability_manager")
@onready var player:PlayerInventory = get_tree().get_first_node_in_group("player")

#State
var dish:Dish
var upgraded_dish:Dish
var all_combinations:Array[Combination]
var active_combinations:Dictionary[Combination, Array]

var all_cards_used:Array[Card]

var mult_flavours:Dictionary[GlobalEnums.Flavour, Array]  = {GlobalEnums.Flavour.SWEET : [1.0],
GlobalEnums.Flavour.SPICY : [1.0], GlobalEnums.Flavour.HEARTY : [1.0], GlobalEnums.Flavour.FRESH : [1.0]}
var mult_nutrition:Array[float] = [1.0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dir_path := "res://resources/combinations/ingame/"
	var paths : PackedStringArray = ResourceLoader.list_directory(dir_path)
	if paths == null: printerr("Could not get Combination folder")
	for path in paths:
		var comb:Combination= ResourceLoader.load(dir_path + path) as Combination
		if comb:
			all_combinations.append(comb)
func start_combinations(new_dish:Dish):
	dish = new_dish
	check_combinations()
	order_active_combinations()
	for combination in active_combinations:
		activate_effects(combination)
		apply_multipliers()
		#UI Combination
		challenge.ui.add_combination_result(combination)
		#Wait for animation end
		await get_tree().create_timer(3).timeout
	challenge.ui.combinations_done()
#region Requirements
func check_combinations():

#Check if dish empty
	if dish.current_cards.size() == 0:
		set_comb_active("Admit Defeat")
		return
#region Stats
#Check for stats
	#Lacking
	if (dish.flavours[GlobalEnums.Flavour.SWEET] < 0
	or dish.flavours[GlobalEnums.Flavour.SPICY] < 0
	or dish.flavours[GlobalEnums.Flavour.HEARTY] < 0
	or dish.flavours[GlobalEnums.Flavour.FRESH] < 0):
		set_comb_active("Lacking")
	
	#Jam
	var fruit_cards = dish.get_all_cards_with_tag(GlobalEnums.Tags.FRUIT)
	if (dish.flavours[GlobalEnums.Flavour.SWEET] > dish.flavours[GlobalEnums.Flavour.SPICY]
	and dish.flavours[GlobalEnums.Flavour.SWEET] > dish.flavours[GlobalEnums.Flavour.HEARTY]
	and dish.flavours[GlobalEnums.Flavour.SWEET] > dish.flavours[GlobalEnums.Flavour.FRESH]
	and fruit_cards.size() >= 3):
		set_comb_active("Jam", [fruit_cards])
	
	#Scoville Hell
	if dish.flavours[GlobalEnums.Flavour.SPICY] > dish.flavours[GlobalEnums.Flavour.FRESH] + dish.flavours[GlobalEnums.Flavour.HEARTY] + dish.flavours[GlobalEnums.Flavour.SWEET]:
		set_comb_active("Scoville Hell")
	
#endregion
#region Tags
#Check for tags
	#Pure
	for tag in dish.get_tags_in_inventory():
		var tag_cards = dish.get_all_cards_with_tag(tag)
		if dish.current_cards.size() == tag_cards.size():
			set_comb_active("Pure", [tag_cards])
			break
	
	#Dry
	if (dish.get_all_cards_with_tag(GlobalEnums.Tags.DRINK).size() == 0
	and dish.get_all_cards_with_tag(GlobalEnums.Tags.OIL).size() == 0
	and dish.get_all_cards_with_tag(GlobalEnums.Tags.FERMENT).size() == 0
	and dish.get_all_cards_with_tag(GlobalEnums.Tags.FRUIT).size() == 0):
		set_comb_active("Dry")
	
	#Salmonella
	if (dish.can_cover_tags([GlobalEnums.Tags.MEAT, GlobalEnums.Tags.FISH, GlobalEnums.Tags.MONSTER])):
		set_comb_active("Salmonella", [dish.get_cards_with_tags([GlobalEnums.Tags.MEAT, GlobalEnums.Tags.FISH, GlobalEnums.Tags.MONSTER])])
	
	#Quishe
	var egg_cards = dish.get_all_cards_with_tag(GlobalEnums.Tags.EGG)
	if (egg_cards.size() >= dish.current_cards.size()/2
	 and dish.current_cards.size() > 1):
		set_comb_active("Quishe", [egg_cards])
	
	#Salad
	var salad_cards = dish.get_cards_with_tags([GlobalEnums.Tags.FRUIT, GlobalEnums.Tags.VEGETABLE])
	if (dish.current_cards.size() > 1
	and salad_cards.size() >= dish.current_cards.size()/2):
		set_comb_active("Salad", [salad_cards])
	
	#Sandwich
	
	var hamwich_cards = dish.get_cards_with_tags([GlobalEnums.Tags.FISH, GlobalEnums.Tags.MEAT])
	if (dish.can_cover_tags([GlobalEnums.Tags.PASTRY, GlobalEnums.Tags.PASTRY, GlobalEnums.Tags.VEGETABLE])
	and hamwich_cards.size() >= 1):
		var sandwich_cards = [dish.get_all_cards_with_tag(GlobalEnums.Tags.PASTRY), dish.get_cards_with_tags([GlobalEnums.Tags.VEGETABLE]), hamwich_cards]
		set_comb_active("Sandwich", sandwich_cards)
	
	#Smoothie
	var smoothie_fruit_cards = dish.get_all_cards_with_tag(GlobalEnums.Tags.FRUIT)
	var smoothie_drink_cards = dish.get_all_cards_with_tag(GlobalEnums.Tags.DRINK)
	if (dish.current_cards.size() > 1
	and smoothie_fruit_cards.size() == smoothie_drink_cards.size()
	and smoothie_fruit_cards.size() > 0):
		set_comb_active("Smoothie", [smoothie_drink_cards, smoothie_fruit_cards])
	
	#Parfait
	if (dish.can_cover_tags([GlobalEnums.Tags.GRAINS, GlobalEnums.Tags.DAIRY, GlobalEnums.Tags.FRUIT])):
		set_comb_active("Parfait", [dish.get_all_cards_with_tag(GlobalEnums.Tags.GRAINS),dish.get_all_cards_with_tag(GlobalEnums.Tags.DAIRY), dish.get_all_cards_with_tag(GlobalEnums.Tags.FRUIT)])
	
	#Deep Fried
	var deep_fried_cards = dish.get_cards_with_tags([GlobalEnums.Tags.MEAT,GlobalEnums.Tags.FISH, 
	GlobalEnums.Tags.MONSTER, GlobalEnums.Tags.FRUIT, GlobalEnums.Tags.VEGETABLE])
	var deep_oil_cards = dish.get_all_cards_with_tag(GlobalEnums.Tags.OIL)
	var oil_amount = deep_oil_cards.size()
	if (oil_amount > dish.get_all_cards_with_tag(GlobalEnums.Tags.MEAT).size()
	and oil_amount > dish.get_all_cards_with_tag(GlobalEnums.Tags.FISH).size()
	and oil_amount > dish.get_all_cards_with_tag(GlobalEnums.Tags.MONSTER).size()
	and oil_amount > dish.get_all_cards_with_tag(GlobalEnums.Tags.FRUIT).size()
	and oil_amount > dish.get_all_cards_with_tag(GlobalEnums.Tags.VEGETABLE).size()
	and deep_fried_cards.size() > 0):
		set_comb_active("Deep Fried", [deep_fried_cards,deep_oil_cards])
	
	#Reinheitsgebot
	if (dish.can_cover_tags([GlobalEnums.Tags.GRAINS, GlobalEnums.Tags.FERMENT, GlobalEnums.Tags.DRINK])
	and dish.current_cards.size() <= 3):
		var beer_cards = dish.get_cards_with_tags([GlobalEnums.Tags.GRAINS, GlobalEnums.Tags.FERMENT, GlobalEnums.Tags.DRINK])
		set_comb_active("Reinheitsgebot", [beer_cards])
	
	#Overseasoned
	var spice_cards = dish.get_all_cards_with_tag(GlobalEnums.Tags.SPICE)
	if spice_cards.size() >= 5:
		set_comb_active("Overseasoned", [spice_cards])
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
	#Fusion Kitchen
	var dish_countries:Array[GlobalEnums.Country] = dish.get_countries_in_inventory()
	if dish.can_cover_countries(dish_countries) and dish_countries.size() >= 4:
		set_comb_active("Fusion Kitchen")
#endregion
#region Abilities
#3-Course Meal
	var course_cards = dish.get_cards_with_abilities([ability_manager.get_ability_by_name("Starter"), ability_manager.get_ability_by_name("Dessert")])
	if (dish.can_cover_abilities([ability_manager.get_ability_by_name("Starter"), ability_manager.get_ability_by_name("Dessert")])
	and dish.current_cards.size() >= 3):
		set_comb_active("3-Course Meal", [course_cards])
#endregion
#region Ingredients
#Check if certain ingredients are in the dish
	#Buttercob
	var corn_cards = dish.get_cards_of_ingredient(item_pool.get_ingredient_by_name("Corn"))
	var butter_cards = dish.get_cards_of_ingredient(item_pool.get_ingredient_by_name("Butter"))
	if (corn_cards.size() > 0
	and butter_cards.size() > 0):
		set_comb_active("Buttercob", [corn_cards, butter_cards])
	
	#Barely Cooked
	if (dish.get_unique_base_ingredients().size() == 1):
		set_comb_active("Barely Cooked")
	
	#Pizza
	var pizza_dough_cards = dish.get_cards_of_ingredient(item_pool.get_ingredient_by_name("Dough"))
	var pizza_tomato_cards = dish.get_cards_of_ingredient(item_pool.get_ingredient_by_name("Tomato"))
	var pizza_cheese_cards = dish.get_cards_of_ingredient(item_pool.get_ingredient_by_name("Cheese"))
	if (pizza_dough_cards.size() > 0
	and pizza_tomato_cards.size() > 0
	and pizza_cheese_cards.size() > 0
	and dish.current_cards.size() >= 4):
		set_comb_active("Pizza",[pizza_dough_cards, pizza_tomato_cards, pizza_cheese_cards])
	
	#Sushi
	var sushi_seaweed_cards = dish.get_cards_of_ingredient(item_pool.get_ingredient_by_name("Seaweed"))
	var sushi_rice_cards = dish.get_cards_of_ingredient(item_pool.get_ingredient_by_name("Rice"))
	var sushi_fish_cards = dish.get_all_cards_with_tag(GlobalEnums.Tags.FISH)
	if (sushi_seaweed_cards.size() > 0
	and sushi_rice_cards.size() > 0
	and sushi_fish_cards.size() > 0):
		set_comb_active("Sushi", [sushi_seaweed_cards, sushi_rice_cards, sushi_fish_cards])
	
	#Mayan Hot Cocoa
	var mayan_cocoa_cards = dish.get_cards_of_ingredient(item_pool.get_ingredient_by_name("Cacao"))
	var mayan_drink_cards = dish.get_all_cards_with_tag(GlobalEnums.Tags.DRINK)
	if (mayan_cocoa_cards.size() > 0
	and mayan_drink_cards.size() > 0):
		set_comb_active("Mayan Hot Cocoa", [mayan_drink_cards, mayan_cocoa_cards])
	
	#Chocolate
	var chocolate_cocoa_cards = dish.get_cards_of_ingredient(item_pool.get_ingredient_by_name("Cacao"))
	var chocolate_sugar_cards = dish.get_cards_of_ingredient(item_pool.get_ingredient_by_name("Sugar"))
	var chocolate_dairy_cards = dish.get_all_cards_with_tag(GlobalEnums.Tags.DAIRY)
	if (chocolate_cocoa_cards.size() > 0
	and chocolate_sugar_cards.size() > 0
	and chocolate_dairy_cards.size() > 0):
		set_comb_active("Chocolate", [chocolate_cocoa_cards, chocolate_dairy_cards, chocolate_sugar_cards])
	
	#Rum
	var rum_sugarcane_cards = dish.get_cards_of_ingredient(item_pool.get_ingredient_by_name("Sugarcane"))
	var rum_ferment_cards = dish.get_all_cards_with_tag(GlobalEnums.Tags.FERMENT)
	if (rum_sugarcane_cards.size() > 0
	and rum_ferment_cards.size() > 0):
		set_comb_active("Rum", [rum_sugarcane_cards, rum_ferment_cards])
	
#Check if certain item orders are correct
	
	#Dolmades
	var wine_leaves_indexes = dish.get_indexes_of_ingredient(item_pool.get_ingredient_by_name("Wine Leaves"))
	var rice_indexes = dish.get_indexes_of_ingredient(item_pool.get_ingredient_by_name("Rice"))
	var dolmades_activates = false
	var dolmades_used_cards
	if wine_leaves_indexes.size() > 0 and rice_indexes.size() > 0:
		for wine_leaves in wine_leaves_indexes:
			for rice in rice_indexes:
				if wine_leaves == rice - 1:
					dolmades_used_cards = [dish.current_cards[wine_leaves], dish.current_cards[rice]]
					dolmades_activates = true
					break
		if dolmades_activates:
			set_comb_active("Dolmades", [dolmades_used_cards])
	
	#Topping
	if (dish.current_cards.size() >= 2
	and dish.current_cards.back().committed_stats.tags.has(GlobalEnums.Tags.SPICE)):
		set_comb_active("Topping",[[dish.current_cards.back()],[dish.current_cards[dish.current_cards.size()-2]]])
#endregion


#region Other Combinations
#check for other combinations HAS TO BE LAST TO BE CHECKED
	#Split Opinion
	var split_opinion_cards = dish.get_cards_of_ingredient(item_pool.get_ingredient_by_name("Pineapple"))
	if (active_combinations.has(get_combination_by_name("Pizza"))
	and split_opinion_cards.size() > 0):
		set_comb_active("Split Opinion", [split_opinion_cards])
	
	#----------------------Check Ingredients in combs--------
	#Sourdough Rising 
	var dough = item_pool.get_ingredient_by_name("Dough")
	var dough_cards = dish.get_cards_of_ingredient(dough)
	if (not dough_cards.is_empty()
	and dish.get_cards_of_ingredient(dough, all_cards_used).is_empty()):
		set_comb_active("Sourdough Rising", [dough_cards])
	#--------------------------Check all combs-----------------
	#Based 
	var based_cards:Dictionary[Card, int]
	#Get combination amount card is used in (no duplicates per combination)
	for combination in active_combinations:
		var combination_cards:Array[Card]
		for card_array:Array in active_combinations[combination]:
			for card:Card in card_array:
				if not combination_cards.has(card):
					if not based_cards.has(card):
						based_cards[card] = 0
					based_cards[card] += 1
					combination_cards.append(card)
	var based_cards_finalists:Array[Card]
	for card in based_cards:
		if based_cards[card] >= 5:
			based_cards_finalists.append(card)
	if not based_cards_finalists.is_empty():
		set_comb_active("Based", [based_cards_finalists])
	
	#check for slop (no other active combinations) -----------LAST
	if active_combinations.is_empty():
		set_comb_active("Slop")
	#endregion
#endregion
#region Effects
func activate_effects(combination):
	upgraded_dish = dish.duplicate()
	#activate based on effect type (if has debuff come last)
	match combination.name:
	#region Buffs
		"Quishe":
			mult_nutrition.append(2.0)
		"3-Course Meal":
			mult_nutrition.append(1.5)
			for flav in mult_flavours:
				mult_flavours[flav].append(1.5)
		"Buttercob":
			mult_nutrition.append(1.25)
		"Dolmades":
			mult_flavours[GlobalEnums.Flavour.HEARTY].append(1.5)
		"Fine Dining":
			for flavour in dish.get_greatest_flavours(dish.flavours):
				mult_flavours[flavour].append(2.5)
		"Fusion Kitchen":
			for flavour in dish.get_greatest_flavours(dish.flavours):
				mult_flavours[flavour].append(1.5)
			for flavour in dish.get_lowest_flavours(dish.flavours):
				mult_flavours[flavour].append(1.5)
		"Pure":
			var pure_greatest_flavours = dish.get_greatest_flavours(dish.flavours)
			for flavour in GlobalEnums.Flavour:
				if GlobalEnums.Flavour[flavour] == GlobalEnums.Flavour.NONE:
					continue
				if pure_greatest_flavours.has(GlobalEnums.Flavour[flavour]):
					continue
				else:
					mult_flavours[GlobalEnums.Flavour[flavour]].append(1.3)
		"Salad":
			mult_flavours[GlobalEnums.Flavour.FRESH].append(1.3)
		"Sushi":
			var sushi_mult:float
			var unique_cards = []
			for card_array in active_combinations[get_combination_by_name("Sushi")]:
				for card in card_array:
					if not unique_cards.has(card):
						unique_cards.append(card)
			sushi_mult = 1.0 + (float(unique_cards.size()) * 0.1)
			mult_nutrition.append(sushi_mult)
		"Topping":
			#Get second to last card
			var second_last_card_flavours = dish.current_cards[dish.current_cards.size()-2].get_flavours()
			for flavour in GlobalEnums.Flavour:
				if GlobalEnums.Flavour[flavour] == GlobalEnums.Flavour.NONE:
					continue
				if second_last_card_flavours[GlobalEnums.Flavour[flavour]] > 0:
					mult_flavours[GlobalEnums.Flavour[flavour]].append(1.3)
		"Deep Fried":
			mult_flavours[GlobalEnums.Flavour.HEARTY].append(2.0)
			mult_nutrition.append(2.0)
			mult_flavours[GlobalEnums.Flavour.FRESH].append(0.5)
			
	#endregion
	#region Debuffs
		"Barely Cooked":
			for flavour in mult_flavours:
				mult_flavours[flavour].append(0.5)
			mult_nutrition.append(0.5)
		"Dry":
			mult_flavours[GlobalEnums.Flavour.FRESH].append(float(3.0/4.0))
		"Lacking":
			mult_nutrition.append(float(2.0/3.0))
		"Overseasoned":
			var spices = dish.get_all_cards_with_tag(GlobalEnums.Tags.SPICE)
			var lowest_flav = dish.get_lowest_flavours(spices)
			for flavour in lowest_flav:
				mult_flavours[flavour].append(0.0)
		"Scoville Hell":
			mult_nutrition.append(0.5)
			for flavour in GlobalEnums.Flavour:
				if GlobalEnums.Flavour[flavour] == GlobalEnums.Flavour.NONE:
					continue
				if GlobalEnums.Flavour[flavour] == GlobalEnums.Flavour.SPICY:
					mult_flavours[GlobalEnums.Flavour[flavour]].append(2.0)
				else:
					mult_flavours[GlobalEnums.Flavour[flavour]].append(0.75)
		"Slop":
			mult_nutrition.append(0.5)
			for flavour in GlobalEnums.Flavour:
				if GlobalEnums.Flavour[flavour] == GlobalEnums.Flavour.NONE:
					continue
				mult_flavours[GlobalEnums.Flavour[flavour]].append(0.5)
		
	#endregion
	#region Player
		"Admit Defeat":
			player.add_morale(-1)
		"Cheap":
			player.add_money(+5)
		"Salmonella":
			player.add_morale(-1)
		"Split Opinion":
			player.add_morale(-1 * ceili(float(player.current_morale)/2.0))
			player.add_money(player.current_money)
		
	#endregion
	#region Create
		"Chocolate":
			var lowest:int = dish.get_all_cards_with_tag(GlobalEnums.Tags.DAIRY).size()
			var sugar = dish.get_cards_of_ingredient(item_pool.get_ingredient_by_name("Sugar")).size()
			var cacao = dish.get_cards_of_ingredient(item_pool.get_ingredient_by_name("Cacao")).size()
			if lowest > sugar:
				lowest = sugar
			if lowest > cacao:
				lowest = cacao
			for i in lowest:
				player.instantiate_card_and_add(item_pool.get_ingredient_by_name("Chocolate"))
		"Jam":
			for i in 2:
				player.instantiate_card_and_add(item_pool.get_ingredient_by_name("Jam"))
		"Mayan Hot Cocoa":
			player.instantiate_card_and_add(item_pool.get_ingredient_by_name("Mayan Cocoa"))
		"Reinheitsgebot":
			for i in 3:
				player.instantiate_card_and_add(item_pool.get_ingredient_by_name("Beer"))
		"Rum":
			player.instantiate_card_and_add(item_pool.get_ingredient_by_name("Rum"))
		"Sourdough Rising":
			player.instantiate_card_and_add(item_pool.get_random_ingredient(true, [GlobalEnums.Tags.PASTRY]))
		"Based":
			#Get Comb Card Tags
			var comb_cards = active_combinations[get_combination_by_name("Based")]
			var activation_tags:Array[GlobalEnums.Tags]
			for card_array in comb_cards:
				for card in card_array:
					for tag in card.committed_stats.tags:
						if not activation_tags.has(tag):
							activation_tags.append(tag)
			for i in 2:
				var empty:Array[Ability] = []
				var rarity:Array[GlobalEnums.Rarity] = [GlobalEnums.Rarity.LEGENDARY]
				player.instantiate_card_and_add(item_pool.get_random_ingredient(true,
				activation_tags,empty,rarity))
	#endregion
	

func apply_multipliers():
	for flavour in GlobalEnums.Flavour:
		if GlobalEnums.Flavour[flavour] == GlobalEnums.Flavour.NONE:
			continue
		var modified_flav:float = float(dish.flavours[GlobalEnums.Flavour[flavour]])
		for mult in mult_flavours[GlobalEnums.Flavour[flavour]]:
			modified_flav = modified_flav * mult
			#Here all single modifiers are applied (FOR animation relevant?)
		upgraded_dish.flavours[GlobalEnums.Flavour[flavour]] = floori(modified_flav)
	var modified:float = float(dish.nutrition)
	for mult in mult_nutrition:
		modified = modified * mult
		#Here all single modifiers are applied (FOR animation relevant?)
	upgraded_dish.nutrition = floori(modified)
	

#endregion

#region Helper
func set_comb_active(c_name, cards = [[]]):
	var combination = get_combination_by_name(c_name)
	if combination == null:
		return
	active_combinations[combination] = cards
	#Cards Used by combination
	for cards_array:Array in cards:
		for card in cards_array:
			if not all_cards_used.has(card):
				all_cards_used.append(card)

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

func get_current_flavour_multiplier_sum(as_percent = false) ->Dictionary:
	var mult_flavours_sum:Dictionary[GlobalEnums.Flavour, float]
	var mult_flavours_sum_int:Dictionary[GlobalEnums.Flavour, int]
	for flavour in GlobalEnums.Flavour:
		if GlobalEnums.Flavour[flavour] == GlobalEnums.Flavour.NONE:
			continue
		var mult_sum:float = 1.0
		for mult in mult_flavours[GlobalEnums.Flavour[flavour]]:
			if mult > 1.0:
				var temp = mult - 1.0
				mult_sum = temp + mult_sum
			else:
				var temp = 1.0 - mult
				mult_sum = mult_sum - temp
		mult_flavours_sum[GlobalEnums.Flavour[flavour]] = mult_sum
		mult_flavours_sum_int[GlobalEnums.Flavour[flavour]] = int(mult_sum * 100)
	if as_percent:
		return mult_flavours_sum_int
	return mult_flavours_sum

func get_current_nutrition_multiplier_sum(as_percent = false):
	var mult_sum:float = 1.0
	for mult in mult_nutrition:
		if mult > 1.0:
			var temp = mult - 1.0
			mult_sum = temp + mult_sum
		else:
			var temp = 1.0 - mult
			mult_sum = mult_sum - temp
	if as_percent:
		return int(mult_sum * 100)
	return mult_sum

func order_active_combinations():
	#Sort the active combinations based on effec type and specific dependencies (addition before multiply)
	return
#endregion
