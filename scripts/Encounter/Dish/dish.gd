class_name Dish
extends Inventory
#PARAMS
@export var nutrition:int = 0
@export_subgroup("Flavour")
@export var sweet:int
@export var spicy:int
@export var hearty:int
@export var fresh:int
@export var ability_sweet:int = 0
@export var ability_spicy:int = 0
@export var ability_hearty:int = 0
@export var ability_fresh:int = 0
@export var ability_nutrition:int = 0

#CACHED COMPS
var random = RandomNumberGenerator.new()
@onready var challenge = get_parent()
@onready var restricted_tags:Array[GlobalEnums.Tags] = challenge.restricted_tags
@onready var dice_disp = $Dice_Display
@onready var dish_ui = $UI

#STATE
var can_add_ingredients = true
var tags:Array[GlobalEnums.Tags]
var dice:Array[RigidBody2D]


func _ready() -> void:
	on_add_card.connect(on_add_to_dish)
	dropping_ingredient.connect(on_drop_ingredient)
	destroying_ingredient.connect(on_destroy_ingredient)
	destroying_all.connect(on_destroy_all_ingredients)
	checking_drop.connect(on_check_drop)
	player_inventory.card_start_drag.connect(on_start_drag)
	player_inventory.card_stop_drag.connect(on_stop_drag)

func start():
	dish_ui.update_nutrition(nutrition)
	dish_ui.update_flavours()

#region inventory signals
func on_start_drag(origin, card):
	if origin == player_inventory:
		abilities.start_drag_preview(card)
func on_stop_drag(origin):
	if origin == player_inventory:
		abilities.stop_drag_preview()

func on_check_drop(origin,card):
	if origin != self:
		return
	#check abilities
	if abilities.on_try_add_to_dish(card) == false:
		can_drop_card = false
	dish_ui.toggle_highlight_pan(can_drop_card)

func on_drop_ingredient(origin, card):
	if origin != self:
		return

func on_add_to_dish(origin,card):
	if origin != self:
		return
	#resets highlights
	if current_cards.size() > 1:
		for i in current_cards:
			dice_disp.reset_highlights(i)
	
	#check for abilities on add
	abilities.on_ingredient_add_to_dish(card)
	roll_ingredient(card)
	recalculate_dish()
	#ui
	dish_ui.update_flavours()
	dish_ui.update_nutrition(nutrition)

func on_destroy_ingredient(origin,card:Node):
	if origin != self:
		return
	remove_card_from_dish(card)

func on_destroy_all_ingredients(origin):
	if origin != self:
		return
	ability_sweet = 0
	ability_spicy = 0
	ability_hearty = 0
	ability_fresh = 0
	ability_nutrition = 0
	for card in current_cards:
		remove_card_from_dish(card)
	sweet = 0
	spicy = 0
	hearty = 0
	fresh = 0
	nutrition = 0
	#ui
	dish_ui.update_flavours()
	dish_ui.update_nutrition(nutrition)
func remove_card_from_dish(card):
	tags.clear()
	for i in current_cards:
		for tag:GlobalEnums.Tags in i.stats.tags:
			if !tags.has(tag):
				tags.append(tag)
	#remove dice values
	nutrition -= card.committed_stats.nutrition
	for die in card.dice:
		subtract_die_value_from_dish(die)
		dice.erase(die)
	abilities.on_ingredient_destroyed_from_dish(card)
	
	#ui
	dice_disp.destroy_dice(card)
	dish_ui.update_nutrition(nutrition)
	dish_ui.update_flavours()
#endregion

func subtract_die_value_from_dish(die):
	match die.flavour:
		GlobalEnums.Flavour.SWEET:
			sweet -= die.number
		GlobalEnums.Flavour.SPICY:
			spicy -= die.number
		GlobalEnums.Flavour.HEARTY:
			hearty -= die.number
		GlobalEnums.Flavour.FRESH:
			fresh -= die.number

func recalculate_dish():
	nutrition = 0
	sweet = 0
	spicy = 0
	hearty = 0
	fresh = 0
	tags.clear()
	
	for card in current_cards:
		print(card.stats.name)
		nutrition += card.committed_stats.nutrition
		
		for tag in card.committed_stats.tags:
			if not tags.has(tag):
				tags.append(tag)
	for die in dice:
		match die.flavour:
			GlobalEnums.Flavour.SWEET:
				sweet += die.number
			GlobalEnums.Flavour.SPICY:
				spicy += die.number
			GlobalEnums.Flavour.HEARTY:
				hearty += die.number
			GlobalEnums.Flavour.FRESH:
				fresh += die.number
	sweet += ability_sweet
	spicy += ability_spicy
	hearty += ability_hearty
	fresh += ability_fresh
	nutrition += ability_nutrition
func finish_dish():
	dice_disp.finish_dish()

func count_ingredient_in_dish(target:Ingredient) -> int:
	var count = 0
	for card in current_cards:
		if card.base_stats == target:
			count += 1
	return count

#region Dice

func roll_ingredient(card:Node, dice_multiplier:int = 1):
	abilities.on_dice_roll(card)
	roll_dice(GlobalEnums.Flavour.SWEET, dice_multiplier*card.committed_stats.sweet,card)
	roll_dice(GlobalEnums.Flavour.SPICY,dice_multiplier*card.committed_stats.spicy,card)
	roll_dice(GlobalEnums.Flavour.HEARTY,dice_multiplier*card.committed_stats.hearty,card)
	roll_dice(GlobalEnums.Flavour.FRESH,dice_multiplier*card.committed_stats.fresh,card)

func roll_dice(flavour,amount,card:Node):
	while amount > 0:
		amount -= 1
		var roll_result = random.randi_range(1,6)
		var die = dice_disp.spawn_die(flavour, roll_result, card)
		dice.append(die)
func reroll_die(die):
	subtract_die_value_from_dish(die)
	var roll_result = random.randi_range(1,6)
	die.display_number(roll_result)
	match die.flavour:
		GlobalEnums.Flavour.SWEET:
			sweet += roll_result
		GlobalEnums.Flavour.SPICY:
			spicy += roll_result
		GlobalEnums.Flavour.HEARTY:
			hearty += roll_result
		GlobalEnums.Flavour.FRESH:
			fresh += roll_result

#endregion
