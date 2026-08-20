extends Inventory
#PARAMS
@export var nutrition:int = 0
@export_subgroup("Flavour")
@export var sweet:int
@export var sour:int
@export var spicy:int
@export var hearty:int
@export var fresh:int

#CACHED COMPS
var random = RandomNumberGenerator.new()
@onready var event_manager = get_node("/root/game/EventManager")
@onready var player_inventory = get_node("/root/game/Player/Inventory")
@onready var abilties = get_node("/root/game/Player/Abilities")
@onready var challenge = get_parent()
@onready var restricted_tags = challenge.restricted_tags
@onready var dice_disp = $Dice_Display
@onready var dish_ui = $UI

#STATE
var can_drop:bool = true
var tags:Array[String]

func _ready() -> void:
	on_add_ingredient.connect(on_add_to_dish)
	on_remove_ingredient.connect(on_remove_from_dish)

func on_add_to_dish(card):
	#check for abilities on add
	abilities.on_ingredient_add_to_dish(card)
	for new_tag in card.stats.tags:
		if !tags.has(new_tag):
			tags.append(new_tag)
	
	roll_ingredient(card)
	
	#ui
	nutrition += card.stats.nutrition
	event_manager.add_to_dish(card)
	
	dish_ui.update_flavours()
	dish_ui.update_nutrition(nutrition)

func on_remove_from_dish(ingredient):
	nutrition -= ingredient.nutrition
	ui.update_nutrition(nutrition)
	tags.clear()
	for i in current_ingredients:
		for tag in i.tags:
			if !tags.has(tag):
				tags.append(tag)

func remove_all_ingredients():
	nutrition = 0
	ui.update_nutrition(nutrition)
	current_ingredients.clear()
	tags.clear()

func destroy_all_ingredients():
	nutrition = 0
	ui.update_nutrition(nutrition)
	for i in current_ingredients:
		i.queue_free()
	current_ingredients.clear()
	tags.clear()

func roll_ingredient(card):
	var dice_multiplier = 1
	var result_multiplier = 1
	dice_disp.reset_highlights()
	abilities.on_dice_roll(card.stats)
	sweet += roll_dice("sweet", dice_multiplier*card.stats.sweet) * result_multiplier
	sour += roll_dice("sour", dice_multiplier*card.stats.sour) * result_multiplier
	spicy += roll_dice("spicy",dice_multiplier*card.stats.spicy) * result_multiplier
	hearty += roll_dice("hearty",dice_multiplier*card.stats.hearty) * result_multiplier
	fresh += roll_dice("fresh",dice_multiplier*card.stats.fresh) * result_multiplier

func roll_dice(flavour,amount):
	var all_result = 0
	while amount > 0:
		print("single dice rolled")
		amount -= 1
		var roll_result = random.randi_range(1,6)
		all_result += roll_result
		dice_disp.spawn_die(flavour, roll_result)
	return all_result

func start():
	dish_ui.update_nutrition(nutrition)

func finish_dish():
	dice_disp.finish_dish()
