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
@onready var restricted_tags = challenge.restricted_tags
@onready var dice_disp = $Dice_Display
@onready var dish_ui = $UI

#STATE
var can_add_ingredients = true
var tags:Array[GlobalEnums.Tags]


func _ready() -> void:
	on_add_ingredient.connect(on_add_to_dish)
	dropping_ingredient.connect(on_drop_ingredient)
	destroying_ingredient.connect(on_destroy_ingredient)
	destroying_all.connect(on_destroy_all_ingredients)
	checking_drop.connect(on_check_drop)

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
	for new_tag in card.stats.tags:
		if !tags.has(new_tag):
			tags.append(new_tag)
	
	roll_ingredient(card)
	
	nutrition += card.stats.nutrition

	event_manager.add_to_dish(card)
	#check for abilities on add
	abilities.on_ingredient_add_to_dish(card)
	
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
	for i in current_ingredients:
		remove_card_from_dish(i)

func remove_card_from_dish(card):
	tags.clear()
	for i in current_ingredients:
		for tag in i.stats.tags:
			if !tags.has(tag):
				tags.append(tag)
	#remove dice values
	nutrition -= card.stats.nutrition
	subtract_dice_values_from_dish(card)
	dice_disp.destroy_dice(card)
	dish_ui.update_nutrition(nutrition)
	dish_ui.update_flavours()
	
	abilities.on_ingredient_destroyed_from_dish(card)
	player_inventory.ui.update_slots()


func subtract_dice_values_from_dish(card):
	for die in card.dice:
		match die.flavour:
			"sweet":
				sweet -= die.number
			"sour":
				sour -= die.number
			"spicy":
				spicy -= die.number
			"hearty":
				hearty -= die.number
			"fresh":
				fresh -= die.number


func roll_ingredient(card:Node):
	var dice_multiplier = 1
	var result_multiplier = 1
	if current_ingredients.size() > 1:
		dice_disp.reset_highlights(current_ingredients[current_ingredients.size()-2])
	abilities.on_dice_roll(card)
	sweet += roll_dice("sweet", dice_multiplier*card.stats.sweet,card) * result_multiplier
	sour += roll_dice("sour", dice_multiplier*card.stats.sour,card) * result_multiplier
	spicy += roll_dice("spicy",dice_multiplier*card.stats.spicy,card) * result_multiplier
	hearty += roll_dice("hearty",dice_multiplier*card.stats.hearty,card) * result_multiplier
	fresh += roll_dice("fresh",dice_multiplier*card.stats.fresh,card) * result_multiplier

func roll_dice(flavour,amount,card:Node):
	var all_result = 0
	while amount > 0:
		amount -= 1
		var roll_result = random.randi_range(1,6)
		all_result += roll_result
		dice_disp.spawn_die(flavour, roll_result, card)
	return all_result

func start():
	dish_ui.update_nutrition(nutrition)
	dish_ui.update_flavours()

func finish_dish():
	dice_disp.finish_dish()
