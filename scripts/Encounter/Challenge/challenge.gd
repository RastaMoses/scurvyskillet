class_name Challenge
extends Control
#PARAMS
@export_category("Requirements")
@export_group("Success")
@export var req_nutrition:int
@export var req_flavours:Dictionary[GlobalEnums.Flavour, int] = {GlobalEnums.Flavour.SWEET: 0, GlobalEnums.Flavour.SPICY: 0,GlobalEnums.Flavour.HEARTY: 0,GlobalEnums.Flavour.FRESH: 0}
@export_group("Partial")
@export var par_nutrition:int
@export var par_flavours:Dictionary[GlobalEnums.Flavour, int] = {GlobalEnums.Flavour.SWEET: 0, GlobalEnums.Flavour.SPICY: 0,GlobalEnums.Flavour.HEARTY: 0,GlobalEnums.Flavour.FRESH: 0}
@export_group("Tag Restrictions")
@export var restricted_tags: Array[GlobalEnums.Tags]
@export_category("Results")
@export_group("Success")
@export var success_title:String = "VICTORY"
@export_multiline() var success_description:String
@export var success_morale: int
@export var success_money: int
@export var s_next_encounter:PackedScene
@export_subgroup("Ingredients")
@export var s_specific_ingredients:Array[Ingredient]
@export var s_random_ingredient_amount:int = 1
@export_subgroup("Random Item Reqs")
@export var s_and_req:bool = false
@export var s_req_rarity:Array[GlobalEnums.Rarity]
@export var s_req_tag:Array[GlobalEnums.Tags]
@export var s_req_ability:Array[Ability]

@export_group("Partial")
@export var partial_title:String = "PARTIAL VICTORY"
@export_multiline() var partial_description:String
@export var partial_morale: int
@export var partial_money: int
@export var p_next_encounter:PackedScene
@export_subgroup("Ingredients")
@export var p_specific_ingredients:Array[Ingredient]
@export var p_random_ingredient_amount:int = 1
@export_subgroup("Random Item Reqs")
@export var p_and_req:bool = false
@export var p_req_rarity:Array[GlobalEnums.Rarity]
@export var p_req_tag:Array[GlobalEnums.Tags]
@export var p_req_ability:Array[Ability]

@export_group("Failure")
@export var failure_title:String = "DEFEAT"
@export_multiline() var failure_description:String
@export var failure_morale: int
@export var failure_money: int
@export var f_next_encounter:PackedScene
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
@onready var reward_screen:RewardScreen = get_tree().get_first_node_in_group("reward_screen")
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
@onready var item_pool = get_tree().get_first_node_in_group("ingredient_pool")
@onready var ability_manager = get_tree().get_first_node_in_group("ability_manager")
@onready var combination_manager:CombinationManager = get_tree().get_first_node_in_group("combination_manager")
@onready var current_dish = $Dish
@onready var map_node = get_parent()
@onready var ui = $UI
@onready var dice_disp = $Dish/Dice_Display

#SIGNAL CONNECTIONS


#STATE
var reward_title
var reward_description
var reward_money:int
var reward_morale:int
var reward_next_encounter:PackedScene
var reward_specific_ingredients:Array[Ingredient]
var reward_random_ingredient_amount:int
var reward_and_req:bool
var reward_req_rarity:Array[GlobalEnums.Rarity]
var reward_req_tag:Array[GlobalEnums.Tags]
var reward_req_ability:Array[Ability]

var combination_reward_ingredients:Dictionary[Combination, Array]
var combination_money_reward:Array[int]
var combination_morale_reward:Array[int]



func _ready() -> void:
	ui.finish_dish_pressed.connect(finish_dish)
	ui.reset_dish_pressed.connect(reset_dish)
#region Helper
func is_restricted_tag(tag):
	return restricted_tags.has(tag)
#endregion
func start():
	current_dish.start()
	ability_manager.on_challenge_start(current_dish)
	ui.update_requirement_stats(current_dish)
func end():
	await ui.end_challenge_pressed
	compare_dish(combination_manager.upgraded_dish)
	give_rewards()
	queue_free()
	
	
func compare_dish(completed_dish):
	if (completed_dish.nutrition < req_nutrition
	or completed_dish.flavours[GlobalEnums.Flavour.SWEET] < req_flavours[GlobalEnums.Flavour.SWEET]
	or completed_dish.flavours[GlobalEnums.Flavour.SPICY] < req_flavours[GlobalEnums.Flavour.SPICY]
	or completed_dish.flavours[GlobalEnums.Flavour.HEARTY] < req_flavours[GlobalEnums.Flavour.HEARTY]
	or completed_dish.flavours[GlobalEnums.Flavour.FRESH] < req_flavours[GlobalEnums.Flavour.FRESH]
	or completed_dish.get_tags_in_inventory().any(is_restricted_tag)): #check if restricted tag is used
		if (completed_dish.nutrition < par_nutrition
		or completed_dish.flavours[GlobalEnums.Flavour.SWEET] < par_flavours[GlobalEnums.Flavour.SWEET]
		or completed_dish.flavours[GlobalEnums.Flavour.SPICY] < par_flavours[GlobalEnums.Flavour.SPICY]
		or completed_dish.flavours[GlobalEnums.Flavour.HEARTY] < par_flavours[GlobalEnums.Flavour.HEARTY]
		or completed_dish.flavours[GlobalEnums.Flavour.FRESH] < par_flavours[GlobalEnums.Flavour.FRESH]
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
	combination_manager.start_combinations(current_dish)
	end()
func reset_dish():
	current_dish.destroy_all_ingredients()

#region Results
func give_rewards():
	var ingredient_rewards:Array[Ingredient]
	if reward_random_ingredient_amount > 0:
		var index = reward_random_ingredient_amount
		while index > 0:
			ingredient_rewards.append(item_pool.get_random_ingredient(reward_and_req,reward_req_tag,reward_req_ability,reward_req_rarity))
			index -= 1
	for i in reward_specific_ingredients:
		ingredient_rewards.append(i)
	reward_screen.start(reward_title, reward_description, reward_money, reward_morale,
	 ingredient_rewards,[], combination_manager.reward_ingredients, 
	combination_manager.reward_random_removed_cards,combination_manager.money_rewards, 
	combination_manager.morale_rewards, reward_next_encounter)

func on_success():
	reward_title = success_title
	reward_description = success_description
	reward_money = success_money
	reward_morale = success_morale
	reward_next_encounter = s_next_encounter
	reward_specific_ingredients = s_specific_ingredients
	reward_random_ingredient_amount = s_random_ingredient_amount
	reward_and_req = s_and_req
	reward_req_rarity = s_req_rarity
	reward_req_tag = s_req_tag
	reward_req_ability = s_req_ability
	end()

func on_partial():
	reward_title = partial_title
	reward_description = partial_description
	reward_money = partial_money
	reward_morale = partial_morale
	reward_next_encounter = p_next_encounter
	reward_specific_ingredients = p_specific_ingredients
	reward_random_ingredient_amount = p_random_ingredient_amount
	reward_and_req = p_and_req
	reward_req_rarity = p_req_rarity
	reward_req_tag = p_req_tag
	reward_req_ability = p_req_ability
	end()

func on_failure():
	reward_title = failure_title
	reward_description = failure_description
	reward_money = failure_money
	reward_morale = failure_morale
	reward_next_encounter = f_next_encounter
	reward_specific_ingredients = f_specific_ingredients
	reward_random_ingredient_amount = f_random_ingredient_amount
	reward_and_req = f_and_req
	reward_req_rarity = f_req_rarity
	reward_req_tag = f_req_tag
	reward_req_ability = f_req_ability
	end()
	
#endregion
