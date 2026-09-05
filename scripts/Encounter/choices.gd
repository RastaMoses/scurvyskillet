class_name Choices
extends Inventory
#PARAMS
@onready var random = RandomNumberGenerator.new()

@export var text:String
@export_group("Reward")
@export var r_money:int
@export var r_morale:int
@export var specific_ingredients:Array[Ingredient]
@export var random_ingredient_amount:int = 1
@export_subgroup("Random Item Reqs")
@export var and_req:bool = false
@export var req_rarity:Array[GlobalEnums.Rarity]
@export var req_tags:Array[GlobalEnums.Tags]
@export var req_ability:Array[Ability]
@export_group("Cost")
@export var c_money:int
@export var c_morale:int
@export_subgroup("Ingredient Cost Requirements")
@export var drop_ingredients:bool
@export var req_specific_ingredients:Array[Ingredient]
@export var ingredient_amount:int
@export var randomIngredients:int
@export var sweet:int
@export var spicy:int
@export var hearty:int
@export var fresh:int
@export var nutrition:int
@export_subgroup("New Encounter")
@export var new_encounter:PackedScene
@export var new_encounter_type:GlobalEnums.EncounterType

#CACHED COMPS

@onready var drop_area = $DropArea
@onready var drop_highlight = $UI/IngredientDrop/DropHighlight
@onready var drop_ui = $UI/IngredientDrop
@onready var ingredient_icon = $UI/IngredientDrop/IngredientIcon
@onready var button = $Button
@onready var button_highlight = $Button/Highlight
@onready var button_text = $Button/RichTextLabel
@onready var drop_area_text = $UI/IngredientDrop/RichTextLabel
var decision_encounter
#STATE


func _ready() -> void:
	button.pressed.connect(on_button_press)
	button_text.text = text
	drop_area_text.text = text
	dropping_ingredient.connect(on_ingredient_dropped)
	checking_drop.connect(on_checking_drop)

func on_checking_drop(origin, card):
	if origin != self:
		return
	var droppable = true
	
	#specific ingredient
	if req_specific_ingredients.size() != 0:
		if not req_specific_ingredients.has(card.base_stats):
			droppable = false
	#check if a tag is required
	if req_tags.size() != 0:
		for i in req_tags:
			if !card.committed_stats.tags.has(i):
				droppable = false
	#check for rarity
	if req_rarity.size() != 0:
		for i in req_rarity:
			if !card.committed_stats.rarity.has(i):
				droppable = false
	drop_highlight.visible = droppable
	can_drop_card = droppable

func on_ingredient_dropped(origin, card):
	if origin != self:
		return
	check_completed()
	

func remove_random():
	var rand_index = random.randi_range(0,player_inventory.current_cards.size()-1)
	ingredient_icon.texture = player_inventory.current_cards[rand_index].get_icon_texture()
	player_inventory.remove_ingredient(player_inventory.current_cards[rand_index])

func check_completed():
	#if amount of ingredients or amount of flavour/nutrition is fullfilled
	#amount
	if (current_cards.size() < ingredient_amount):
		return
	#values
	var sweet_sum = 0
	for i in current_cards:
		sweet_sum += i.committed_stats.sweet
	print("Choice Sweet Sum on check completed")
	print(sweet_sum)
	if sweet_sum < sweet:
		return
		
	var spicy_sum = 0
	for i in current_cards:
		spicy_sum += i.committed_stats.spicy
	if spicy_sum < spicy:
		return
	
	var hearty_sum = 0
	for i in current_cards:
		hearty_sum += i.committed_stats.hearty
	if hearty_sum < hearty:
		return
	
	var fresh_sum = 0
	for i in current_cards:
		fresh_sum += i.committed_stats.fresh
	if fresh_sum < fresh:
		return
	
	var nutrition_sum = 0
	for i in current_cards:
		nutrition_sum += i.committed_stats.nutrition
	if nutrition_sum < nutrition:
		return
	complete()

func button_available():
	if player_inventory.current_money < c_money or player_inventory.current_morale < c_morale:
		disable_button()
		return
	if player_inventory.current_cards.size()<randomIngredients:
		disable_button()
		return
	if drop_ingredients:
		disable_button()
		return
	enable_button()

func give_rewards():
	player_inventory.add_money(r_money)
	player_inventory.add_morale(r_morale)
	if random_ingredient_amount > 0:
		var index = random_ingredient_amount
		while index > 0:
			player_inventory.instantiate_card_and_add(item_pool.get_random_ingredient(and_req,req_tags,req_ability,req_rarity))
			index -= 1
	for i in specific_ingredients:
		
		player_inventory.instantiate_card_and_add(i)

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


func _on_button_mouse_entered() -> void:
	button_highlight.visible = true


func _on_button_mouse_exited() -> void:
	button_highlight.visible = false


func _on_drop_area_mouse_exited() -> void:
	drop_highlight.visible = false
