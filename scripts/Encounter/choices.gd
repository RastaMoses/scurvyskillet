extends Inventory
#PARAMS
@onready var player_inventory = get_node("/root/game/Player/Inventory")
@onready var random = RandomNumberGenerator.new()

@export var text:String
@export_group("Reward")
@export var r_money:int
@export var r_morale:int
@export var r_random_ingredient:bool = false
@export var r_ingredients:Array[Resource]
@export_group("Cost")
@export var c_money:int
@export var c_morale:int
@export_subgroup("Ingredient Cost Requirements")
@export var drop_ingredients:bool
@export var ingredient_amount:int
@export var randomIngredients:int
@export var sweet:int
@export var sour:int
@export var spicy:int
@export var hearty:int
@export var fresh:int
@export var nutrition:int
@export_subgroup("New Encounter")
@export var new_encounter:PackedScene

#CACHED COMPS
@onready var decision_encounter = get_parent()
@onready var drop_area = $DropArea
@onready var drop_ui = $UI/IngredientDrop
@onready var ingredient_icon = $UI/IngredientDrop/IngredientIcon
@onready var button = $Button
@onready var button_text = $Button/RichTextLabel
@onready var drop_area_text = $UI/IngredientDrop/RichTextLabel

#STATE
var encounter_type = "decision"


func _ready() -> void:
	button.pressed.connect(on_button_press)
	button_text.text = text
	drop_area_text.text = text
	on_add_ingredient.connect(on_ingredient_added)

func on_ingredient_added():
	check_completed()

func remove_random():
	var rand_index = random.randi_range(0,player_inventory.current_ingredients.size()-1)
	ingredient_icon.texture = player_inventory.current_ingredients[rand_index].get_icon_texture()
	player_inventory.remove_ingredient(player_inventory.current_ingredients[rand_index])

func check_completed():
	#if amount of ingredients or amount of flavour/nutrition is fullfilled
	#amount
	if (current_ingredients.size() < ingredient_amount):
		return
	#values
	var sweet_sum = 0
	for i in current_ingredients:
		sweet_sum += i.sweet
	if sweet_sum < sweet:
		return
		
	var sour_sum = 0
	for i in current_ingredients:
		sour_sum += i.sour
	if sour_sum < sour:
		return
		
	var spicy_sum = 0
	for i in current_ingredients:
		spicy_sum += i.spicy
	if spicy_sum < spicy:
		return
	
	var hearty_sum = 0
	for i in current_ingredients:
		hearty_sum += i.hearty
	if hearty_sum < hearty:
		return
	
	var fresh_sum = 0
	for i in current_ingredients:
		fresh_sum += i.fresh
	if fresh_sum < fresh:
		return
	
	var nutrition_sum = 0
	for i in current_ingredients:
		nutrition_sum += i.nutrition
	if nutrition_sum < nutrition:
		return
	complete()

func button_available():
	if player_inventory.current_money < c_money or player_inventory.current_morale < c_morale:
		disable_button()
		return
	if player_inventory.current_ingredients.size()<randomIngredients:
		disable_button()
		return
	if drop_ingredients:
		disable_button()
		return
	enable_button()

func give_rewards():
	player_inventory.add_money(r_money)
	player_inventory.add_morale(r_morale)
	if r_random_ingredient:
		var rand = random.randi_range(0,r_ingredients.size()-1)
		player_inventory.instantiate_card_from_resource(r_ingredients[rand])
	else:
		for i in r_ingredients:
			player_inventory.instantiate_card_from_resource(i)

func take_cost():
	player_inventory.add_money(-c_money)
	player_inventory.add_morale(-c_morale)
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
