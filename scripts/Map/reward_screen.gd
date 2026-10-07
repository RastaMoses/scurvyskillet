class_name RewardScreen
extends Inventory
@export var reward_slot:PackedScene
@export_group("Nodes")
@export var grid_container:GridContainer
@export var title_label:RichTextLabel
@export var description_label:RichTextLabel
@export var close_button:ButtonUI

var reward_money = 0
var reward_morale = 0
var combination_reward_ingredients:Dictionary[Combination, Array]
var combination_remove_ingredients:Dictionary[Combination, Array]
var combination_moneys:Dictionary[Combination, int]
var combination_morales:Dictionary[Combination, int]
var encounter_reward_ingredients:Array[Ingredient]
var combination_slots:Dictionary[Node, Combination]
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

func start(title:String, description:String, money:int, morale:int,
add_ingredients:Array[Ingredient], remove_ingredients:Array[Card] = [], combination_ingredients:Dictionary[Combination, Array] = {},
combination_remove:Dictionary[Combination, Array] = {}, combination_money:Dictionary[Combination, int] = {},combination_morale:Dictionary[Combination, int] = {},
new_encounter = null):
	#Reset
	combination_slots.clear()
	destroy_all_ingredients()
	ui.set_all_slots_negative(false)
	for child in grid_container.get_children():
		child.queue_free()
	#Add new
	reward_money = money
	reward_morale = morale
	encounter_reward_ingredients = add_ingredients.duplicate()
	combination_moneys = combination_money.duplicate()
	combination_morales = combination_morale.duplicate()
	combination_reward_ingredients = combination_ingredients.duplicate()
	combination_remove_ingredients = combination_remove.duplicate()
	cost_ingredients = remove_ingredients
	title_label.text = title
	description_label.text = description
	next_encounter = new_encounter
	#Set Display
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
	if reward_money > 0 or reward_money < 0:
		var new_slot = reward_slot.instantiate()
		grid_container.add_child(new_slot)
		new_slot.set_money(reward_money)
	if reward_morale > 0 or reward_morale < 0:
		var new_slot = reward_slot.instantiate()
		grid_container.add_child(new_slot)
		new_slot.set_morale(reward_money)
	
	if combination_moneys.size() > 0:
		for combination in combination_moneys:
			var new_slot = reward_slot.instantiate()
			grid_container.add_child(new_slot)
			new_slot.set_money(combination_moneys[combination])
			combination_slots[new_slot] = combination
			if combination_moneys[combination] < 0:
				new_slot.toggle_icon_bg_negative(true)
	if combination_morales.size() > 0:
		for combination in combination_morales:
			var new_slot = reward_slot.instantiate()
			grid_container.add_child(new_slot)
			new_slot.set_morale(combination_morales[combination])
			combination_slots[new_slot] = combination
			if combination_morales[combination] < 0:
				new_slot.toggle_icon_bg_negative(true)
	if cost_ingredients.size() > 0:
		for card in cost_ingredients:
			var new_card = add_card(card)
			var slot = ui.get_card_slot(new_card)
			card.stats.uses = 1
			ui.set_slot_negative(slot, true)
	if encounter_reward_ingredients.size() > 0:
		for card in encounter_reward_ingredients:
			var new_card = instantiate_card_and_add(card)
	if combination_remove_ingredients.size() > 0:
		for combination in combination_remove_ingredients:
			for card in combination_remove_ingredients[combination]:
				var new_card = add_card(card)
				var slot = ui.get_card_slot(new_card)
				card.stats.uses = 1
				ui.set_slot_negative(slot, true)
				combination_slots[ui.get_card_slot(new_card)] = combination
	if combination_reward_ingredients.size() > 0:
		for combination in combination_reward_ingredients:
			for ingredient in combination_reward_ingredients[combination]:
				var new_card = instantiate_card_and_add(ingredient)
				combination_slots[ui.get_card_slot(new_card)] = combination

func give_rewards():
	player_inventory.add_money(reward_money)
	player_inventory.add_morale(reward_morale)
	for ingredient in encounter_reward_ingredients:
		player_inventory.instantiate_card_and_add(ingredient)
	for card in cost_ingredients:
		player_inventory.remove_ingredient(card)

func end_rewards():
	give_rewards()
	toggle_open(false)
	if next_encounter != null:
		map_loader.current_map.current_encounter.load_encounter(next_encounter)
	else:
		map_loader.current_map.current_encounter.end_encounter()

func toggle_disable_buttons(value):
	close_button.toggle_disabled(value)

func set_hover_combination(slot):
	if combination_slots.has(slot):
		for comb_slot in combination_slots:
			if combination_slots[comb_slot] == combination_slots[slot]:
				#Set comb slot to highlight
				slot.toggle_icon_bg_combination(true)
func stop_hover_combination(slot):
	if combination_slots.has(slot):
		for comb_slot in combination_slots:
			if combination_slots[comb_slot] == combination_slots[slot]:
				#Set comb slot to unhighlight
				slot.toggle_icon_bg_combination(false)
