class_name Challenge
extends Control

#PARAMS
@export_category("Requirements")
@export_group("Success")
@export var req_nutrition:int
@export var req_sweet:int
@export var req_spicy:int
@export var req_hearty:int
@export var req_fresh:int
@export_group("Partial")
@export var par_nutrition:int
@export var par_sweet:int
@export var par_spicy:int
@export var par_hearty:int
@export var par_fresh:int
@export_group("Tag Restrictions")
@export var restricted_tags: Array[GlobalEnums.Tags]


@export_category("Results")
@export_group("Success")
@export var success_morale: int
@export var success_money: int
@export_subgroup("Ingredients")
@export var s_specific_ingredients:Array[Ingredient]
@export var s_random_ingredient_amount:int = 1
@export_subgroup("Random Item Reqs")
@export var s_and_req:bool = false
@export var s_req_rarity:Array[GlobalEnums.Rarity]
@export var s_req_tag:Array[GlobalEnums.Tags]
@export var s_req_ability:Array[Ability]

@export_group("Partial")
@export var partial_morale: int
@export var partial_money: int
@export_subgroup("Ingredients")
@export var p_specific_ingredients:Array[Ingredient]
@export var p_random_ingredient_amount:int = 1
@export_subgroup("Random Item Reqs")
@export var p_and_req:bool = false
@export var p_req_rarity:Array[GlobalEnums.Rarity]
@export var p_req_tag:Array[GlobalEnums.Tags]
@export var p_req_ability:Array[Ability]

@export_group("Failure")
@export var failure_morale: int
@export var failure_money: int
@export_subgroup("Ingredients")
@export var f_specific_ingredients:Array[Ingredient]
@export var f_random_ingredient_amount:int = 1
@export_subgroup("Random Item Reqs")
@export var f_and_req:bool = false
@export var f_req_rarity: Array[GlobalEnums.Rarity]
@export var f_req_tag:Array[GlobalEnums.Tags]
@export var f_req_ability:Array[Ability]

#CACHED COMPS
@onready var player_inventory = get_tree().get_first_node_in_group("player")
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
@onready var item_pool = get_tree().get_first_node_in_group("ingredient_pool")
@onready var ability_manager = get_tree().get_first_node_in_group("ability_manager")
@onready var combination_manager:CombinationManager = get_tree().get_first_node_in_group("combination_manager")
@onready var dish_node = $Dish
@onready var map_node = get_parent()
@onready var ui = $UI
@onready var dice_disp = $Dish/Dice_Display

#SIGNAL CONNECTIONS


#STATE
var reward_money:int
var reward_morale:int
var reward_specific_ingredients:Array[Ingredient]
var reward_random_ingredient_amount:int
var reward_and_req:bool
var reward_req_rarity:Array[GlobalEnums.Rarity]
var reward_req_tag:Array[GlobalEnums.Tags]
var reward_req_ability:Array[Ability]

func _ready() -> void:
	event_manager.large_view_toggled.connect(toggle_large_view)
	ui.finish_dish_pressed.connect(finish_dish)
	ui.reset_dish_pressed.connect(reset_dish)
#region Helper
func is_restricted_tag(tag):
	return restricted_tags.has(tag)
#endregion
func start():
	dish_node.start()
	ability_manager.on_challenge_start(dish_node)

func end():
	await ui.end_challenge_pressed
	compare_dish(combination_manager.upgraded_dish)
	map_node.end_encounter()
	give_rewards()
	queue_free()

#region Results
func give_rewards():
	player_inventory.add_money(reward_money)
	player_inventory.add_morale(reward_morale)
	if reward_random_ingredient_amount > 0:
		var index = reward_random_ingredient_amount
		while index > 0:
			player_inventory.instantiate_card_and_add(item_pool.get_random_ingredient(reward_and_req,reward_req_tag,reward_req_ability,reward_req_rarity))
			index -= 1
	for i in reward_specific_ingredients:
		player_inventory.instantiate_card_and_add(i)

func on_success():
	reward_money = success_money
	reward_morale = success_morale
	reward_specific_ingredients = s_specific_ingredients
	reward_random_ingredient_amount = s_random_ingredient_amount
	reward_and_req = s_and_req
	reward_req_rarity = s_req_rarity
	reward_req_tag = s_req_tag
	reward_req_ability = s_req_ability
	
	end()

func on_partial():
	reward_money = partial_money
	reward_morale = partial_morale
	reward_specific_ingredients = p_specific_ingredients
	reward_random_ingredient_amount = p_random_ingredient_amount
	reward_and_req = p_and_req
	reward_req_rarity = p_req_rarity
	reward_req_tag = p_req_tag
	reward_req_ability = p_req_ability
	
	end()

func on_failure():
	reward_money = failure_money
	reward_morale = failure_morale
	reward_specific_ingredients = f_specific_ingredients
	reward_random_ingredient_amount = f_random_ingredient_amount
	reward_and_req = f_and_req
	reward_req_rarity = f_req_rarity
	reward_req_tag = f_req_tag
	reward_req_ability = f_req_ability
	end()
	
#endregion

func compare_dish(completed_dish):
	if (completed_dish.nutrition < req_nutrition
	or completed_dish.flavours[GlobalEnums.Flavour.SWEET] < req_sweet
	or completed_dish.flavours[GlobalEnums.Flavour.SPICY] < req_spicy
	or completed_dish.flavours[GlobalEnums.Flavour.HEARTY] < req_hearty
	or completed_dish.flavours[GlobalEnums.Flavour.FRESH] < req_fresh
	or completed_dish.get_tags_in_inventory().any(is_restricted_tag)): #check if restricted tag is used
		if (completed_dish.nutrition < par_nutrition
		or completed_dish.flavours[GlobalEnums.Flavour.SWEET] < par_sweet
		or completed_dish.flavours[GlobalEnums.Flavour.SPICY] < par_spicy
		or completed_dish.flavours[GlobalEnums.Flavour.HEARTY] < par_hearty
		or completed_dish.flavours[GlobalEnums.Flavour.FRESH] < par_fresh
		or completed_dish.get_tags_in_inventory().any(is_restricted_tag)): #check if restricted tag is used
			#fail
			on_failure()
		else:
			on_partial()
			#partial
			
	else:
		on_success()
		#success

func finish_dish():
	dice_disp.finish_dish()
	event_manager.dish_finish_animation_done()
	await event_manager.on_dish_finish_anim_done
	ui.toggle_result_screen(true)
	combination_manager.start_combinations(dish_node)
	ui.update_flavours(combination_manager.upgraded_dish)
	ui.update_nutrition(combination_manager.upgraded_dish.nutrition)
	end()
func reset_dish():
	dish_node.destroy_all_ingredients()

#region UI functions
func toggle_large_view(value):
	ui.toggle_disable_buttons(value)

#endregion
