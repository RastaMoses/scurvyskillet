class_name Ability
extends Resource

@export_category("Basic")
@export var name:String
@export var continuous:bool = false
@export var stackable:bool = false
@export var duration:int = 0

#region Params
#region Conditions Params
#------------------CONDITIONS--------------------
@export_category("Conditions")

@export_group("Timing")
@export_subgroup("Dish")
@export var try_add_to_dish_cond:bool = false
@export var this_add_to_dish_cond:bool = false
@export var any_other_add_to_dish_cond:bool = false
@export var finish_dish_cond:bool = false
@export_subgroup("Encounter")
@export var start_encounter_cond:bool = false
@export var end_encounter_cond:bool = false
@export_subgroup("Shop")
@export var sell_cond:bool = false
@export_group("Card")
@export_group("Dish")
@export_subgroup("Maximum")
@export var sweet_cond_dish_max:int = -1
@export var spicy_cond_dish_max:int = -1
@export var fresh_cond_dish_max:int = -1
@export var hearty_cond_dish_max:int = -1
@export var nutrition_cond_dish_max:int = -1
@export var dice_count_cond_dish_max:int = -1
@export var ingredient_count_cond_dish_max:int = -1
@export_subgroup("Minimum")
@export var sweet_cond_dish_min:int = -1
@export var spicy_cond_dish_min:int = -1
@export var fresh_cond_dish_min:int = -1
@export var hearty_cond_dish_min:int = -1
@export var nutrition_cond_dish_min:int = -1
@export var dice_count_cond_dish_min:int = -1
@export var ingredient_count_cond_dish_min:int = -1
@export_subgroup("Ingredients")
@export var dish_tags_cond:Array[GlobalEnums.Tags] = []
@export var specific_ingredients_in_dish_cond:Array[Ingredient] = []
#endregion
#region Effects Params
#------------------EFFECTS--------------------
@export_category("Effects")

@export_group("Target")
@export var self_target:bool = false
@export var played_ingredient_target:bool = false
@export var all_ingredients_in_dish_target:bool = false
@export var all_in_player_inventory_target:bool = false
@export var all_dice_target:bool = false
@export var dish_target:bool = false
@export_subgroup("Target Filter")
@export var specific_ingredient_filter:Ingredient = null
@export var card_abilities_filter:Array[Ability] = []
@export var card_tags_filter:Array[GlobalEnums.Tags] = []
@export var card_rarity_filter:Array[GlobalEnums.Rarity] = []
@export var flavours_filter:Array[GlobalEnums.Flavour] = []
@export_subgroup("Dice")
@export var dice_number_filter:Array[int] = []
@export_group("Dish")
@export var limit_ingredients_int:int = -1
@export var can_only_play:bool = false
@export var can_not_play:bool = false
@export var add_stats_dish:bool = false
@export var equal_stats_to_flavour:GlobalEnums.Flavour = GlobalEnums.Flavour.NONE
@export var multiply_dish:bool = false
@export_group("Add Ingredient")
@export var add_specific_ingredients_effect:Array[Ingredient] = []
@export var add_random_ingredients_amount_effect:int = 0
@export_subgroup("Random Ingr Filter")
@export var rand_ing_tag_filter:Array[GlobalEnums.Tags] = []
@export var rand_ing_rarity_filter:Array[GlobalEnums.Rarity] = []
@export_group("Stats")
@export var sweet_effect:int = 0
@export var spicy_effect:int = 0
@export var fresh_effect:int = 0
@export var hearty_effect:int = 0
@export var nutrition_effect:int = 0
@export var uses_effect:int = 0
@export_subgroup("Multiplier")
@export var times_tag_in_dish:Array[GlobalEnums.Tags] = []
@export var times_dice_amount:int = 0
@export_group("Dice")
@export var reroll:bool = false
@export var set_dice_number:int = 0
@export_group("Player")
@export var morale_gain:int = 0
#endregion
#endregion
#---------------------CONDITIONS CHECKING----------------------
