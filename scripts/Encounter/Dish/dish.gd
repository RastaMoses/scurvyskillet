extends Node
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
@onready var abilities = get_node("/root/root/Player/Abilities")
@onready var inventory = get_node("/root/root/Player/Inventory")
@onready var event_manager = get_node("/root/root/EventManager")
@onready var challenge = get_parent()
@onready var restricted_tags = challenge.restricted_tags
signal nutrition_change(new_value)
@onready var ui = $UI
@onready var dice_disp = $Dice_Display
#STATE
var can_drop:bool = true
var current_ingredients: Array[Node]
var tags:Array[String]

func check_can_drop(data):
	#try_add abilities
	if abilities.on_try_add_ingredient(data) == false:
		return false
	#check if a tag is restricted
	if restricted_tags.size() != 0:
		for i in restricted_tags:
			if data.tags.has(i):
				return false
	return can_drop

func add_ingredient(ingredient):
	#check for abilities on add
	abilities.on_ingredient_add_to_dish(ingredient)
	#add ingredient
	current_ingredients.append(ingredient)
	ingredient.reparent(self)
	inventory.remove_ingredient(ingredient)
	
	#add tags to the dish
	for new_tag in ingredient.tags:
		if !tags.has(new_tag):
			tags.append(new_tag)
	nutrition += ingredient.nutrition
	event_manager.add_to_dish(ingredient)
	roll_ingredient(ingredient)
	ui.update_flavours()
	ui.update_nutrition(nutrition)
	
	#dice display
	dice_disp.reset_highlights()
	
	for i in ingredient.sweet:
		dice_disp.spawn_die("sweet")
	for i in ingredient.sour:
		dice_disp.spawn_die("sour")
	for i in ingredient.spicy:
		dice_disp.spawn_die("spicy")
	for i in ingredient.hearty:
		dice_disp.spawn_die("hearty")
	for i in ingredient.fresh:
		dice_disp.spawn_die("fresh")
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
	abilities.on_dice_roll(ingredient)
	sweet += roll_dice(dice_multiplier*ingredient.sweet) * result_multiplier
	sour += roll_dice(dice_multiplier*ingredient.sour) * result_multiplier
	spicy += roll_dice(dice_multiplier*ingredient.spicy) * result_multiplier
	hearty += roll_dice(dice_multiplier*ingredient.hearty) * result_multiplier
	fresh += roll_dice(dice_multiplier*ingredient.fresh) * result_multiplier

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
