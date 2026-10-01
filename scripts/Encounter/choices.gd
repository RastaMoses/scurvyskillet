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
@export var req_flavours:Dictionary[GlobalEnums.Flavour, int] = {GlobalEnums.Flavour.SWEET : 0,
GlobalEnums.Flavour.SPICY : 0, GlobalEnums.Flavour.HEARTY : 0, GlobalEnums.Flavour.FRESH : 0}
@export var req_nutrition:int
@export_subgroup("New Encounter")
@export var new_encounter:PackedScene
@export var new_encounter_type:GlobalEnums.EncounterType

#CACHED COMPS

@onready var drop_area:DropArea = $DropArea
@onready var ingredient_icon = $DropArea/IngredientIcon
@onready var button = $Button
@onready var stat_disp:StatsDisplayer = $StatsDisplayer
var decision_encounter

var interactable = true
#STATE


func _ready() -> void:
	init_inventory()
	button.left_clicked.connect(on_button_press)
	dropping_ingredient.connect(on_ingredient_dropped)
	checking_drop.connect(on_checking_drop)

#region Order
func start():
	button.set_text(text)
	drop_area.set_text(text)
	check_completed()
	if not drop_ingredients:
		stat_disp.visible = false
	check_button_available()
	
func end():
	if new_encounter == null:
		decision_encounter.end()
	queue_free()

func complete():
	give_rewards()
	take_cost()
	end()

#endregion

#region Inventory Signal

func on_checking_drop(origin, card):
	if origin != self:
		return
	var droppable = interactable
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
	can_drop_card = droppable

func on_ingredient_dropped(origin, _card):
	if origin != self:
		return
	check_completed()
	
#endregion
#region Checking
func check_completed():
	if not drop_ingredients:
		return
	#if amount of ingredients or amount of flavour/nutrition is fullfilled
	#amount
	var completed = true
	if (current_cards.size() < ingredient_amount):
		return
	#values
	var flavour_sums = get_flavours_sum()
	var flavour_dif:Dictionary[GlobalEnums.Flavour, int]
	for flavour in GlobalEnums.Flavour:
		if GlobalEnums.Flavour[flavour] == GlobalEnums.Flavour.NONE:
			continue
		flavour_dif[GlobalEnums.Flavour[flavour]] = req_flavours[GlobalEnums.Flavour[flavour]] - flavour_sums[GlobalEnums.Flavour[flavour]]
		if flavour_sums[GlobalEnums.Flavour[flavour]] < req_flavours[GlobalEnums.Flavour[flavour]]:
			completed = false
	stat_disp.update_flavours(flavour_dif)
	var sum_nutrition = 0
	for i in current_cards:
		sum_nutrition += i.committed_stats.nutrition
	stat_disp.update_nutrition(req_nutrition - sum_nutrition)
	if sum_nutrition < req_nutrition:
		completed = false
	if completed:
		complete()
#endregion
#region Getting
#endregion

#region Reward

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

#endregion
#region Costs

func take_cost():
	player_inventory.add_money(-c_money)
	player_inventory.add_morale(-c_morale)
	for i in randomIngredients:
		remove_random()
	if new_encounter != null:
		decision_encounter.load_new_encounter(new_encounter)

func remove_random():
	var rand_index = random.randi_range(0,player_inventory.current_cards.size()-1)
	ingredient_icon.texture = player_inventory.current_cards[rand_index].get_icon_texture()
	player_inventory.remove_ingredient(player_inventory.current_cards[rand_index])

#endregion

func check_button_available():
	if player_inventory.current_money < c_money or player_inventory.current_morale < c_morale:
		disable_button()
		return
	if player_inventory.current_cards.size()<randomIngredients:
		disable_button()
		return
	if drop_ingredients:
		disable_button()
		drop_area.set_visible(true)
		return
	drop_area.set_visible(false)
	enable_button()

func on_button_press():
	complete()

func disable_button():
	button.toggle_disabled(true)
	if (drop_ingredients):
		button.visible = false

func enable_button():
	button.visible = true
	button.toggle_disabled(false)

func toggle_interactable(value):
	if value:
		interactable = true
		check_button_available()
	else:
		interactable = false
		disable_button()
