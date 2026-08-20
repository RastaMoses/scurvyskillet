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
signal nutrition_change(new_value)
@onready var dice_disp = $Dice_Display
@onready var dish_ui = $UI

#STATE
var can_drop:bool = true
var tags:Array[String]

func _ready() -> void:
	on_add_ingredient.connect(on_add_to_dish)

func on_add_to_dish(card):
	#check for abilities on add
	abilities.on_ingredient_add_to_dish(card)
	for new_tag in card.stats.tags:
		if !tags.has(new_tag):
			tags.append(new_tag)
	#dice display
	dice_disp.reset_highlights()
	for i in card.stats.sweet:
		dice_disp.spawn_die("sweet")
	for i in card.stats.sour:
		dice_disp.spawn_die("sour")
	for i in card.stats.spicy:
		dice_disp.spawn_die("spicy")
	for i in card.stats.hearty:
		dice_disp.spawn_die("hearty")
	for i in card.stats.fresh:
		dice_disp.spawn_die("fresh")
	#ui
	nutrition += card.stats.nutrition
	event_manager.add_to_dish(card)
	roll_ingredient(card)
	
	dish_ui.update_flavours()
	dish_ui.update_nutrition(nutrition)

func remove_ingredient(ingredient):
	nutrition -= ingredient.nutrition
	nutrition_change.emit(nutrition)
	current_ingredients.erase(ingredient)
	tags.clear()
	for i in current_ingredients:
		for tag in i.tags:
			if !tags.has(tag):
				tags.append(tag)

func remove_all_ingredients():
	nutrition = 0
	nutrition_change.emit(nutrition)
	current_ingredients.clear()
	tags.clear()

func destroy_all_ingredients():
	nutrition = 0
	nutrition_change.emit(nutrition)
	for i in current_ingredients:
		i.queue_free()
	current_ingredients.clear()
	tags.clear()

func roll_ingredient(ingredient):
	var dice_multiplier = 1
	var result_multiplier = 1
	abilities.on_dice_roll(ingredient.stats)
	sweet += roll_dice(dice_multiplier*ingredient.stats.sweet) * result_multiplier
	sour += roll_dice(dice_multiplier*ingredient.stats.sour) * result_multiplier
	spicy += roll_dice(dice_multiplier*ingredient.stats.spicy) * result_multiplier
	hearty += roll_dice(dice_multiplier*ingredient.stats.hearty) * result_multiplier
	fresh += roll_dice(dice_multiplier*ingredient.stats.fresh) * result_multiplier

func roll_dice(amount):
	var result = 0
	while amount > 0:
		amount -= 1
		result += random.randi_range(1,6)
	return result

func start():
	nutrition_change.emit(0)

func finish_dish():
	dice_disp.finish_dish()
