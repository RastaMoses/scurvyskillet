extends Node2D

#PARAMS
@export_group("Requirements")
@export_subgroup("Success")
@export var req_nutrition:int
@export var req_sweet:int
@export var req_sour:int
@export var req_spicy:int
@export var req_hearty:int
@export var req_fresh:int
@export_subgroup("Partial")
@export var par_nutrition:int
@export var par_sweet:int
@export var par_sour:int
@export var par_spicy:int
@export var par_hearty:int
@export var par_fresh:int
@export_group("Tag Restrictions")
@export var restricted_tags: Array[String]
@export_group("Results")
@export_subgroup("Success")
@export var success_ingredients: Array[PackedScene]
@export var success_morale: int
@export var success_money: int
@export_subgroup("Partial")
@export var partial_ingredients: Array[PackedScene]
@export var partial_morale: int
@export var partial_money: int
@export_subgroup("Failure")
@export var failure_ingredients: Array[PackedScene]
@export var failure_morale: int
@export var failure_money: int

#CACHED COMPS
var event_manager
var inventory
var dish_node

#STATE


func _ready() -> void:
	event_manager = get_node("/root/root/EventManager")
	inventory = get_node("/root/root/Player/Inventory")
	dish_node = $Dish
	

func on_success():
	inventory.current_money += success_money
	inventory.current_morale += success_morale
	for i in success_ingredients:
		inventory.instantiate_ingredient(i)
	print("Succeeded the challenge")

func on_partial():
	inventory.current_money += partial_money
	inventory.current_morale += partial_morale
	for i in partial_ingredients:
		inventory.instantiate_ingredient(i)
	print("Partialed the challenge")

func on_failure():
	inventory.current_money += failure_money
	inventory.current_morale += failure_morale
	for i in failure_ingredients:
		inventory.instantiate_ingredient(i)
	print("Failed the challenge")

func is_restricted_tag(tag):
	return restricted_tags.has(tag)
	
func compare_ghoulash():
	pass

func compare_dish(completed_dish):
	if (completed_dish.dish.nutrition < req_nutrition
	or completed_dish.dish.sweet < req_sweet
	or completed_dish.dish.sour < req_sour
	or completed_dish.dish.spicy < req_spicy
	or completed_dish.dish.hearty < req_hearty
	or completed_dish.dish.fresh < req_fresh
	or completed_dish.dish.tags.any(is_restricted_tag)): #check if restricted tag is used
		if (completed_dish.dish.nutrition < par_nutrition
		or completed_dish.dish.sweet < par_sweet
		or completed_dish.dish.sour < par_sour
		or completed_dish.dish.spicy < par_spicy
		or completed_dish.dish.hearty < par_hearty
		or completed_dish.dish.fresh < par_fresh
		or completed_dish.dish.tags.any(is_restricted_tag)): #check if restricted tag is used
			#fail
			on_failure()
		else:
			on_partial()
			#partial
			
	else:
		on_success()
		#success

func reset_dish():
	for i in dish_node.current_ingredients:
		inventory.add_ingredient(i)
	dish_node.remove_all_ingredients()
	
#UI Elements
func start_challenge():
	event_manager.encounter_start()
	display_dish()

func end_challenge():
	event_manager.encounter_end()
	queue_free()

func display_dish():
	#visually show dish node
	dish_node.show()
	
func hide_dish():
	dish_node.hide()


func on_reset_button_pressed() -> void:
	reset_dish()


func _on_roll_dish_pressed() -> void:
	dish_node.roll_dish()
