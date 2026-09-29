class_name Dish
extends Inventory
#PARAMS
@export var nutrition:int = 0
@export_subgroup("Flavour")
@export var flavours:Array[int] = [0,0,0,0,0]
@export var ability_flavours:Array[int] = [0,0,0,0,0]
@export var ability_nutrition:int = 0

#CACHED COMPS
var random = RandomNumberGenerator.new()
@onready var challenge = get_parent()
@onready var dice_disp = $Dice_Display

#STATE
var can_add_ingredients = true
var dice:Array[RigidBody2D]


func _ready() -> void:
	init_inventory()
	on_add_card.connect(on_add_to_dish)
	dropping_ingredient.connect(on_drop_ingredient)
	destroying_ingredient.connect(on_destroy_ingredient)
	destroying_all.connect(on_destroy_all_ingredients)
	checking_drop.connect(on_check_drop)
	player_inventory.card_start_drag.connect(on_start_drag)
	player_inventory.card_stop_drag.connect(on_stop_drag)

func start():
	challenge.ui.update_nutrition(nutrition)
	challenge.ui.update_flavours(self)

func subtract_die_value_from_dish(die):
	flavours[die.flavour] -= die.number

func add_die_value_to_dish(die):
	flavours[die.flavour] += die.number

func recalculate_dish():
	nutrition = 0
	for i in flavours:
		i = 0
	
	for card in current_cards:
		nutrition += card.committed_stats.nutrition
	for die in dice:
		add_die_value_to_dish(die)
	#add ability stats
	for i in range(flavours.size()):
		flavours[i] += ability_flavours[i]
	nutrition += ability_nutrition
func finish_dish():
	dice_disp.finish_dish()

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
	challenge.ui.toggle_highlight_pan(can_drop_card)

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
	challenge.ui.update_flavours(self)
	challenge.ui.update_nutrition(nutrition)

func on_destroy_ingredient(origin,card:Node):
	if origin != self:
		return
	remove_card_from_dish(card)

func on_destroy_all_ingredients(origin):
	if origin != self:
		return
	ability_flavours[GlobalEnums.Flavour.SWEET] = 0
	ability_flavours[GlobalEnums.Flavour.SPICY] = 0
	ability_flavours[GlobalEnums.Flavour.HEARTY] = 0
	ability_flavours[GlobalEnums.Flavour.FRESH] = 0
	ability_nutrition = 0
	for card in current_cards:
		remove_card_from_dish(card)
	flavours[GlobalEnums.Flavour.SWEET] = 0
	flavours[GlobalEnums.Flavour.SPICY] = 0
	flavours[GlobalEnums.Flavour.HEARTY] = 0
	flavours[GlobalEnums.Flavour.FRESH] = 0
	nutrition = 0
	#ui
	challenge.ui.update_flavours(self)
	challenge.ui.update_nutrition(nutrition)
func remove_card_from_dish(card):
	#remove dice values
	nutrition -= card.committed_stats.nutrition
	for die in card.dice:
		subtract_die_value_from_dish(die)
		dice.erase(die)
	abilities.on_ingredient_destroyed_from_dish(card)
	
	#ui
	dice_disp.destroy_dice(card)
	challenge.ui.update_nutrition(nutrition)
	challenge.ui.update_flavours(self)
#endregion

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
			flavours[GlobalEnums.Flavour.SWEET] += roll_result
		GlobalEnums.Flavour.SPICY:
			flavours[GlobalEnums.Flavour.SPICY] += roll_result
		GlobalEnums.Flavour.HEARTY:
			flavours[GlobalEnums.Flavour.HEARTY] += roll_result
		GlobalEnums.Flavour.FRESH:
			flavours[GlobalEnums.Flavour.FRESH] += roll_result

#endregion

#region Helper
func get_greatest_flavour() -> GlobalEnums.Flavour:
	var flavours_dup = flavours.duplicate()
	var max_index:int = 0
	for i in range(1, flavours_dup.size()):
		if flavours_dup[i] > flavours[max_index]:
			max_index = i
	return max_index

func get_lowest_flavour() ->GlobalEnums.Flavour:
	var flavours_dup = flavours.duplicate()
	var min_index:int = 0
	for i in range(1, flavours_dup.size()):
		if flavours_dup[i] < flavours[min_index]:
			min_index = i
	return min_index
#endregion
