class_name Ability
extends Resource

@export_category("Basic")
@export var name:String
@export var stack_ability:bool = false

#------------------CONDITIONS--------------------
@export_category("Conditions")

@export_group("Time")
@export_subgroup("Dish")
@export var on_this_add_to_dish_cond:bool = false
@export var on_any_add_to_dish_cond:bool = false
@export var on_finish_dish_cond:bool = false
@export_subgroup("Encounter")
@export var on_start_encounter_cond:bool = false
@export var on_end_encounter_cond:bool = false
@export_subgroup("Shop")
@export var on_sell_cond:bool = false

@export_group("Dish")
@export_subgroup("Maximum")
@export var sweet_cond_dish_max:int = -1
@export var spicy_cond_dish_max:int = -1
@export var fresh_cond_dish_max:int = -1
@export var hearty_cond_dish_max:int = -1
@export var nutrition_cond_dish_max:int = -1
@export var ingredient_count_cond_dish_max:int = -1
@export var dice_count_cond_dish_max:int = -1
@export_subgroup("Minimum")
@export var sweet_cond_dish_min:int = -1
@export var spicy_cond_dish_min:int = -1
@export var fresh_cond_dish_min:int = -1
@export var hearty_cond_dish_min:int = -1
@export var nutrition_cond_dish_min:int = -1
@export var ingredient_count_cond_dish_min:int = -1
@export var dice_count_cond_dish_min:int = -1
@export_subgroup("Tags")
@export var tags_cond:Array[GlobalEnums.Tags] = []


#------------------EFFECTS--------------------
@export_category("Effects")

@export_group("Target")
@export var self_target:bool = false
@export var all_ingredients_in_dish_target:bool = false
@export var all_in_player_inventory_target:bool = false
@export_subgroup("Dice")
@export var all_dice_target:bool = false
@export var all_sweet_dice_target:bool = false
@export var all_spicy_dice_target:bool = false
@export var all_fresh_dice_target:bool = false
@export var all_hearty_dice_target:bool = false

@export_group("Dish_Specific")
@export_subgroup("Limit")
@export var limit_amount_in_dish:int = -1


func check_can_add_to_dish(dish):
	pass

func check_add_to_dish(dish):
	pass
