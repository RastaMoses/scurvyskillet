class_name Ability
extends Resource

@export_category("Basic")
@export var name:String
@export var continuous_ability:bool = false
@export var duration:int = 1

#region Params
#region Conditions Params
#------------------CONDITIONS--------------------
@export_category("Conditions")

@export_group("Time")
@export_subgroup("Dish")
@export var try_add_to_dish_cond:bool = false
@export var this_add_to_dish_cond:bool = false
@export var any_add_to_dish_cond:bool = false
@export var finish_dish_cond:bool = false
@export_subgroup("Encounter")
@export var start_encounter_cond:bool = false
@export var end_encounter_cond:bool = false
@export_subgroup("Shop")
@export var sell_cond:bool = false

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
@export var ingredients_in_dish_cond:Array[Ingredient]
#endregion
#region Effects Params
#------------------EFFECTS--------------------
@export_category("Effects")

@export_group("Target")
@export var self_target:bool = false
@export var next_ingredient_target:bool = false
@export var all_ingredients_in_dish_target:bool = false
@export var all_in_player_inventory_target:bool = false
@export var all_dice_of_flavours:Array[GlobalEnums.Flavour]
@export_subgroup("Dice")
@export var all_dice_target:bool = false
@export var all_sweet_dice_target:bool = false
@export var all_spicy_dice_target:bool = false
@export var all_fresh_dice_target:bool = false
@export var all_hearty_dice_target:bool = false

@export_group("Dish_Specific")
@export_subgroup("Limit")
@export var limit_amount_in_dish_effect:int = -1

@export_group("Add Ingredient")
@export var add_specific_ingredients_effect:Array[Ingredient]
@export var add_random_ingredients_amount_effect:int = 0
#endregion
#endregion
#---------------------CONDITIONS CHECKING----------------------
