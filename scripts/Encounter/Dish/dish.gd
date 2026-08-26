class_name Dish
extends Inventory
#PARAMS
@export var nutrition:int = 0
@export_subgroup("Flavour")
@export var sweet:int
var sour:int
@export var spicy:int
@export var hearty:int
@export var fresh:int

#CACHED COMPS
var random = RandomNumberGenerator.new()
@onready var challenge = get_parent()
@onready var restricted_tags:Array[GlobalEnums.Tags] = challenge.restricted_tags
@onready var dice_disp = $Dice_Display
@onready var dish_ui = $UI

#STATE
var can_add_ingredients = true
var tags:Array[GlobalEnums.Tags]


func _ready() -> void:
	on_add_card.connect(on_add_to_dish)
	dropping_ingredient.connect(on_drop_ingredient)
	destroying_ingredient.connect(on_destroy_ingredient)
	destroying_all.connect(on_destroy_all_ingredients)
	checking_drop.connect(on_check_drop)

func start():
	dish_ui.update_nutrition(nutrition)
	dish_ui.update_flavours()

func on_check_drop(origin,card):
	if origin != self:
		return
	can_drop_card = abilities.on_try_add_to_dish(card)
	dish_ui.toggle_highlight_pan(can_drop_card)

func on_drop_ingredient(origin, card):
	if origin != self:
		return

func on_add_to_dish(origin,card):
	if origin != self:
		return
	for new_tag:GlobalEnums.Tags in card.stats.tags:
		if !tags.has(new_tag):
			tags.append(new_tag)
	roll_ingredient(card)
	nutrition += card.stats.nutrition
	event_manager.add_to_dish(card)
	#check for abilities on add
	card.reset_preview()
	abilities.on_ingredient_add_to_dish(card)
	#ui
	dish_ui.update_flavours()
	dish_ui.update_nutrition(nutrition)
	for temp in player_inventory.current_cards:
		temp.reset_preview()
		abilities.preview_card_abilities_add_dish(temp)

func on_destroy_ingredient(origin,card:Node):
	if origin != self:
		return
	remove_card_from_dish(card)

func on_destroy_all_ingredients(origin):
	if origin != self:
		return
	for i in current_cards:
		remove_card_from_dish(i)
	for temp in player_inventory.current_cards:
		temp.reset_preview()

func remove_card_from_dish(card):
	tags.clear()
	for i in current_cards:
		for tag:GlobalEnums.Tags in i.stats.tags:
			if !tags.has(tag):
				tags.append(tag)
	#remove dice values
	nutrition -= card.stats.nutrition
	for die in card.dice:
		subtract_die_value_from_dish(die)
	abilities.on_ingredient_destroyed_from_dish(card)
	
	#ui
	dice_disp.destroy_dice(card)
	dish_ui.update_nutrition(nutrition)
	dish_ui.update_flavours()
	for temp in player_inventory.current_cards:
		temp.reset_preview()
		abilities.preview_card_abilities_add_dish(temp)
	player_inventory.ui.update_slots()

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

func roll_ingredient(card:Node):
	var dice_multiplier = 1
	var result_multiplier = 1
	if current_cards.size() > 1:
		for i in current_cards:
			dice_disp.reset_highlights(i)
	abilities.on_dice_roll(card)
	sweet += roll_dice(GlobalEnums.Flavour.SWEET, dice_multiplier*card.stats.sweet,card) * result_multiplier
	spicy += roll_dice(GlobalEnums.Flavour.SPICY,dice_multiplier*card.stats.spicy,card) * result_multiplier
	hearty += roll_dice(GlobalEnums.Flavour.HEARTY,dice_multiplier*card.stats.hearty,card) * result_multiplier
	fresh += roll_dice(GlobalEnums.Flavour.FRESH,dice_multiplier*card.stats.fresh,card) * result_multiplier

func roll_dice(flavour,amount,card:Node):
	var all_result = 0
	while amount > 0:
		amount -= 1
		var roll_result = random.randi_range(1,6)
		all_result += roll_result
		dice_disp.spawn_die(flavour, roll_result, card)
	return all_result

func finish_dish():
	dice_disp.finish_dish()

func count_ingredient_in_dish(target:Ingredient) -> int:
	var count = 0
	for card in current_cards:
		if card.base_stats == target:
			count += 1
	return count

#region Ability Effects


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
