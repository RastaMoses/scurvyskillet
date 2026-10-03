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

func _ready() -> void:
	init_inventory()
	close_button.left_clicked.connect(end_rewards)
	toggle_open(false)

func start(title:String, description:String, money:int, morale:int, ingredients:Array[Ingredient]):
	reward_money = money
	reward_morale = morale
	reward_ingredients = ingredients
	title_label.text = title
	description_label.text = description
	destroy_all_ingredients()
	toggle_open(true)

func toggle_open(value):
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
	if reward_ingredients.size() > 0:
		for ingredient in reward_ingredients:
			instantiate_card_and_add(ingredient)

func give_rewards():
	player_inventory.add_money(reward_money)
	player_inventory.add_morale(reward_morale)
	for ingredient in reward_ingredients:
		player_inventory.instantiate_card_and_add(ingredient)

func end_rewards():
	give_rewards()
	toggle_open(false)
