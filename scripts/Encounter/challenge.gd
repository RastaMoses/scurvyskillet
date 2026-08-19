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
@export_group("UI Elements")
@export var map_icon:Texture

#CACHED COMPS
@onready var inventory = get_node("/root/root/Player/Inventory")
@onready var dish_node = $Dish
@onready var map_node = get_parent()

#STATE
var encounter_type = "challenge"

func on_success():
	inventory.current_money += success_money
	inventory.current_morale += success_morale
	for i in success_ingredients:
		inventory.instantiate_ingredient(i)
	print("Succeeded the challenge")
	end()

func on_partial():
	inventory.current_money += partial_money
	inventory.current_morale += partial_morale
	for i in partial_ingredients:
		inventory.instantiate_ingredient(i)
	print("Partialed the challenge")
	end()

func on_failure():
	inventory.current_money += failure_money
	inventory.current_morale += failure_morale
	for i in failure_ingredients:
		inventory.instantiate_ingredient(i)
	print("Failed the challenge")
	end()

func is_restricted_tag(tag):
	return restricted_tags.has(tag)
	
func use_ghoulash():
	var ghoulash # get ghoulash as dish
	compare_dish(ghoulash)
	pass

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

func reset_dish():
	for i in dish_node.current_ingredients:
		inventory.add_ingredient(i)
	dish_node.remove_all_ingredients()
	
#UI Elements
func start():
	display_dish()
	dish_node.start()
	inventory.ui.update_position(true)

func end():
	map_node.end_encounter()
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
