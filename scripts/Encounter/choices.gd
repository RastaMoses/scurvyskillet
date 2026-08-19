extends Control
#PARAMS
@onready var inventory = get_node("/root/root/Player/Inventory")
@onready var random = RandomNumberGenerator.new()

@export_group("Reward")
@export var r_money:int
@export var r_morale:int
@export var r_random_ingredient:bool = false
@export var r_ingredients:Array[PackedScene]
@export_group("Cost")
@export var c_money:int
@export var c_morale:int
@export_subgroup("Ingredient Cost Requirements")
@export var drop_ingredients:bool
@export var ingredient_amount:int
@export var specific_ingredients:Array[String]
@export var randomIngredients:int
@export var tags:Array[String]
@export var sweet:int
@export var sour:int
@export var spicy:int
@export var hearty:int
@export var fresh:int
@export var nutrition:int
@export var rarity:int = -1
@export_subgroup("New Encounter")
@export var new_encounter:PackedScene

#CACHED COMPS
@onready var decision_encounter = get_parent()
@onready var drop_area = $DropArea
@onready var drop_ui = $UI/IngredientDrop
@onready var ingredient_icon = $UI/IngredientDrop/IngredientIcon
@onready var button = $Button

#STATE
var ingredients: Array[Node]
var encounter_type = "decision"


func _ready() -> void:
	button.pressed.connect(on_button_press)
	

func add_ingredient(ingredient):
	#necessary for drop area script and to check for rarity or smth
	inventory.remove_ingredient(ingredient)
	ingredients.append(ingredient)
	ingredient.reparent(self)
	ingredient_icon.texture = ingredient.get_icon_texture()
	check_completed()

func remove_random():
	var rand_index = random.randi_range(0,inventory.current_ingredients.size()-1)
	ingredient_icon.texture = inventory.current_ingredients[rand_index].get_icon_texture()
	inventory.destroy_ingredient(inventory.current_ingredients[rand_index])

func check_completed():
	#if amount of ingredients or amount of flavour/nutrition is fullfilled
	#amount
	if (ingredients.size() < ingredient_amount):
		return
	#values
	var sweet_sum = 0
	for i in ingredients:
		sweet_sum += i.sweet
	if sweet_sum < sweet:
		return
		
	var sour_sum = 0
	for i in ingredients:
		sour_sum += i.sour
	if sour_sum < sour:
		return
		
	var spicy_sum = 0
	for i in ingredients:
		spicy_sum += i.spicy
	if spicy_sum < spicy:
		return
	
	var hearty_sum = 0
	for i in ingredients:
		hearty_sum += i.hearty
	if hearty_sum < hearty:
		return
	
	var fresh_sum = 0
	for i in ingredients:
		fresh_sum += i.fresh
	if fresh_sum < fresh:
		return
	
	var nutrition_sum = 0
	for i in ingredients:
		nutrition_sum += i.nutrition
	if nutrition_sum < nutrition:
		return
	
	complete()

func check_can_drop(data):
	#check for requirements
	#undroppable items (curses)
	if data.undroppable:
		return false
	#specific ingredient
	if specific_ingredients.size() != 0:
		if specific_ingredients.has(data.ingredient_name):
			return true
	#check if a tag is required
	if tags.size() != 0:
		for i in tags:
			if data.tags.has(i):
				return true
	#check for rarity
	if rarity != -1:
		if data.rarity == rarity:
			return true
		else:
			return false
	return true

func button_available():
	if inventory.current_money < c_money or inventory.current_morale < c_morale:
		disable_button()
		return
	if inventory.current_ingredients.size()<randomIngredients:
		disable_button()
		return
	if drop_ingredients:
		disable_button()
		return
	enable_button()

func give_rewards():
	inventory.change_money(inventory.current_money + r_money)
	inventory.change_morale(inventory.current_morale + r_morale)
	if r_random_ingredient:
		var rand = random.randi_range(0,r_ingredients.size()-1)
		inventory.instantiate_ingredient(r_ingredients[rand])
	else:
		for i in r_ingredients:
			inventory.instantiate_ingredient(i)

func take_cost():
	inventory.change_money(inventory.current_money - c_money)
	inventory.change_morale(inventory.current_morale - c_morale)
	for i in randomIngredients:
		remove_random()
	if new_encounter != null:
		decision_encounter.load_new_encounter(new_encounter)

func on_button_press():
	complete()
	
func complete():
	give_rewards()
	take_cost()
	end()

func disable_button():
	button.disabled = true
	if (drop_ingredients):
		button.visible = false
func enable_button():
	button.visible = true
	button.disabled = false
	

func enable_drop_area():
	drop_area.visible = drop_ingredients
	drop_ui.visible = drop_ingredients
	

func start():
	button_available()
	enable_drop_area()
	
func end():
	if new_encounter == null:
		decision_encounter.end()
	queue_free()
