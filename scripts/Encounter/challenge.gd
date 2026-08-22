class_name Challenge
extends Control

#PARAMS
@export_category("Requirements")
@export_group("Success")
@export var req_nutrition:int
@export var req_sweet:int
var req_sour:int
@export var req_spicy:int
@export var req_hearty:int
@export var req_fresh:int
@export_group("Partial")
@export var par_nutrition:int
@export var par_sweet:int
var par_sour:int
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
@export_group("UI Elements")
@export var map_icon:Texture

#CACHED COMPS
@onready var player_inventory = get_tree().get_first_node_in_group("player")
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
@onready var item_pool = get_tree().get_first_node_in_group("ingredient_pool")
@onready var ability_manager = get_tree().get_first_node_in_group("ability_manager")
@onready var dish_node = $Dish
@onready var map_node = get_parent()
@onready var ui = $UI

#SIGNAL CONNECTIONS


#STATE
var inv_save:Array[Node]
var reward_money:int
var reward_morale:int
var reward_specific_ingredients:Array[Ingredient]
var reward_random_ingredient_amount:int
var reward_and_req:bool
var reward_req_rarity:Array[GlobalEnums.Rarity]
var reward_req_tag:Array[GlobalEnums.Tags]
var reward_req_ability:Array[Ability]

func give_rewards():
	player_inventory.add_money(reward_money)
	player_inventory.add_morale(reward_morale)
	if reward_random_ingredient_amount > 0:
		var index = reward_random_ingredient_amount
		while index > 0:
			player_inventory.add_ingredient(item_pool.get_random_ingredient(reward_and_req,reward_req_tag,reward_req_ability,reward_req_rarity))
			index -= 1
	for i in reward_specific_ingredients:
		player_inventory.add_ingredient(i)


func on_success():
	reward_money = success_money
	reward_morale = success_morale
	reward_specific_ingredients = s_specific_ingredients
	reward_random_ingredient_amount = s_random_ingredient_amount
	reward_and_req = s_and_req
	reward_req_rarity = s_req_rarity
	reward_req_tag = s_req_tag
	reward_req_ability = s_req_ability
	give_rewards()
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
	give_rewards()
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
	give_rewards()
	end()

func is_restricted_tag(tag):
	return restricted_tags.has(tag)
	

func compare_dish(completed_dish):
	if (completed_dish.nutrition < req_nutrition
	or completed_dish.sweet < req_sweet
	or completed_dish.sour < req_sour
	or completed_dish.spicy < req_spicy
	or completed_dish.hearty < req_hearty
	or completed_dish.fresh < req_fresh
	or completed_dish.tags.any(is_restricted_tag)): #check if restricted tag is used
		if (completed_dish.nutrition < par_nutrition
		or completed_dish.sweet < par_sweet
		or completed_dish.sour < par_sour
		or completed_dish.spicy < par_spicy
		or completed_dish.hearty < par_hearty
		or completed_dish.fresh < par_fresh
		or completed_dish.tags.any(is_restricted_tag)): #check if restricted tag is used
			#fail
			on_failure()
		else:
			on_partial()
			#partial
			
	else:
		on_success()
		#success


func finish_dish():
	dish_node.finish_dish()
	await event_manager.on_dish_finish_anim_done
	compare_dish(dish_node)

#UI Elements
func start():
	display_dish()
	dish_node.start()
	player_inventory.ui.update_position(true)
	ability_manager.on_challenge_start(dish_node)

func end():
	map_node.end_encounter()
	queue_free()

func display_dish():
	#visually show dish node
	dish_node.show()
	
func hide_dish():
	dish_node.hide()

func on_reset_button_pressed() -> void:
	dish_node.destroy_all_ingredients()

func _on_roll_dish_pressed() -> void:
	finish_dish()
