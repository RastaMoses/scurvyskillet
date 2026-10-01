class_name Dish
extends Inventory
#PARAMS
@export var nutrition:int = 0
@export_subgroup("Flavour")
@export var flavours:Dictionary[GlobalEnums.Flavour, int]
@export var ability_flavours:Dictionary[GlobalEnums.Flavour, int]
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
	for flavour in GlobalEnums.Flavour:
		if GlobalEnums.Flavour[flavour] == GlobalEnums.Flavour.NONE:
			continue
		flavours[GlobalEnums.Flavour[flavour]] = 0
		ability_flavours[GlobalEnums.Flavour[flavour]] = 0
	
func start():
	challenge.ui.update_stats(self)

func subtract_die_value_from_dish(die):
	flavours[die.flavour] -= die.number

func add_die_value_to_dish(die):
	flavours[die.flavour] += die.number

func recalculate_dish():
	nutrition = 0
	for i in flavours:
		flavours[i] = 0
	for card in current_cards:
		nutrition += card.committed_stats.nutrition
	for die in dice:
		add_die_value_to_dish(die)
	#add ability stats
	for i in GlobalEnums.Flavour:
		if GlobalEnums.Flavour[i] == GlobalEnums.Flavour.NONE:
			continue
		flavours[GlobalEnums.Flavour[i]] += ability_flavours[GlobalEnums.Flavour[i]]
	nutrition += ability_nutrition
	

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
	challenge.ui.update_stats(self)

func on_destroy_ingredient(origin,card:Node):
	if origin != self:
		return
	remove_card_from_dish(card)

func on_destroy_all_ingredients(origin):
	if origin != self:
		return
	for flavour in ability_flavours:
		ability_flavours[flavour] = 0
	ability_nutrition = 0
	for flavour in flavours:
		flavours[flavour] = 0
	nutrition = 0
	for card in current_cards:
		remove_card_from_dish(card)
	#ui
	challenge.ui.update_stats(self)
func remove_card_from_dish(card):
	#remove dice values
	nutrition -= card.committed_stats.nutrition
	for die in card.dice:
		subtract_die_value_from_dish(die)
		dice.erase(die)
	abilities.on_ingredient_destroyed_from_dish(card)
	
	#ui
	dice_disp.destroy_dice(card)
	challenge.ui.update_stats(self)
#endregion

#region Dice

func roll_ingredient(card:Node, dice_multiplier:int = 1):
	abilities.on_dice_roll(card)
	for flavour in GlobalEnums.Flavour:
		if GlobalEnums.Flavour[flavour] == GlobalEnums.Flavour.NONE:
			continue
		roll_dice(flavour,dice_multiplier * (card.get_flavours()[GlobalEnums.Flavour[flavour]]), card)

func roll_dice(flavour,amount,card:Node):
	while amount > 0:
		amount -= 1
		var roll_result = random.randi_range(1,6)
		var die = dice_disp.spawn_die(GlobalEnums.Flavour[flavour], roll_result, card)
		dice.append(die)
func reroll_die(die):
	subtract_die_value_from_dish(die)
	var roll_result = random.randi_range(1,6)
	die.display_number(roll_result)
	flavours[die.flavour] += roll_result

#endregion
