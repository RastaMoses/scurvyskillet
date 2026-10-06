class_name RewardScreen
extends Inventory

@export_group("Nodes")
@export var grid_container:GridContainer
@export var title_label:RichTextLabel
@export var description_label:RichTextLabel
@export var close_button:ButtonUI
@export var money_slot:Control
@export var money_text:RichTextLabel
@export var morale_slot:Control
@export var morale_text:RichTextLabel

var reward_money = 0
var reward_morale = 0
var reward_ingredients:Array[Ingredient]
var cost_ingredients:Array[Card]
var next_encounter:PackedScene
var map:Map

@onready var map_loader = get_tree().get_first_node_in_group("map_loader")
@onready var large_card = get_tree().get_first_node_in_group("card_large_view")

func _ready() -> void:
	init_inventory()
	close_button.left_clicked.connect(end_rewards)
	event_manager.large_view_toggled.connect(toggle_disable_buttons)
	toggle_open(false)

func start(title:String, description:String, money:int, morale:int, add_ingredients:Array[Ingredient] = [], remove_ingredients:Array[Card] = [], new_encounter = null):
	reward_money = money
	reward_morale = morale
	reward_ingredients = add_ingredients
	cost_ingredients = remove_ingredients
	title_label.text = title
	description_label.text = description
	next_encounter = new_encounter
	destroy_all_ingredients()
	set_inventory_display()
	toggle_open(true)
	

func toggle_open(value):
	if value:
		large_card.set_slot_position(1)
	else:
		large_card.set_slot_position(0)
	self.visible = value
	close_button.toggle_disabled(!value)

func set_inventory_display():
	if reward_money > 0:
		money_slot.visible
		money_text.text = "+" + str(reward_money)
	elif reward_money < 0:
		money_slot.visible
		money_text.text = str(reward_money)
	else:
		money_slot.visible = false
	if reward_morale > 0:
		morale_slot.visible
		morale_text.text = "+" + str(reward_morale)
	elif reward_morale < 0:
		morale_slot.visible
		morale_text.text = str(reward_morale)
	else:
		morale_slot.visible = false
	ui.set_all_slots_negative(false)
	if cost_ingredients.size() > 0:
		for card in cost_ingredients:
			add_card(card)
		for card in current_cards:
			card.stats.uses = 1
			ui.set_slot_negative(card, true)
	if reward_ingredients.size() > 0:
		for ingredient in reward_ingredients:
			instantiate_card_and_add(ingredient)

func give_rewards():
	player_inventory.add_money(reward_money)
	player_inventory.add_morale(reward_morale)
	for ingredient in reward_ingredients:
		player_inventory.instantiate_card_and_add(ingredient)
	for card in cost_ingredients:
		player_inventory.remove_ingredient(card)

func end_rewards():
	give_rewards()
	toggle_open(false)
	if next_encounter != null:
		map_loader.current_map.current_encounter.load_new_encounter(next_encounter)


func _on_money_slot_button_pressed() -> void:
	large_card.cancel_large_view_pressed()


func _on_morale_slot_button_pressed() -> void:
	large_card.cancel_large_view_pressed()

func toggle_disable_buttons(value):
	close_button.toggle_disabled(value)
