
class_name Inventory
extends Node

@export var card_prefab:PackedScene
var current_cards: Array[Node]
@export var starting_ingredients: Array[Ingredient]
@export var ui:Control
@export var can_stack_uses:bool = true
@export_group("Can Drop Reqs")
@export var cd_tags:Array[GlobalEnums.Tags]
@export var cd_ingredients:Array[Ingredient]
@export var cd_rarity:Array[GlobalEnums.Rarity] #-1 to disable
#CACHED COMPS
@onready var abilities = get_tree().get_first_node_in_group("ability_manager")
@onready var player_inventory = get_tree().get_first_node_in_group("player")
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
@onready var item_pool = get_tree().get_first_node_in_group("ingredient_pool")
#SIGNALS
signal on_add_card(origin,card)
signal dropping_ingredient(origin, card)
signal on_remove_ingredient(origin,card)
signal checking_drop(origin,card)
signal destroying_ingredient(origin,card)
signal destroying_all(origin)
#STATE
var can_drop_card = true

func _ready() -> void:
	for i in starting_ingredients:
		instantiate_card_and_add(i)

func destroy_ingredient(card:Node):
	destroying_ingredient.emit(self,card)
	current_cards.erase(card)
	if ui != null:
		ui.update_slots()
	if card.get_parent() == self:
		card.queue_free()

func destroy_all_ingredients():
	destroying_all.emit(self)
	for i in current_cards:
		i.queue_free()
	current_cards.clear()
	if ui != null:
		ui.update_slots()

func remove_ingredient(card):
	if !current_cards.has(card):
		return
	
	if !card.stats.unlimited_uses:
		change_ingredient_uses(card, -1)
		current_cards.erase(card)
		distribute_uses(card)
	if ui != null:
		ui.update_slots()
	on_remove_ingredient.emit(self,card)

func drop_ingredient(card):
	dropping_ingredient.emit(self, card)
	add_card(card)
	player_inventory.remove_ingredient(card)

func instantiate_card_and_add(resource:Ingredient):
	var temp_card:Node = card_prefab.instantiate()
	temp_card.set_stats(resource.duplicate(true), resource)
	var new_card = add_card(temp_card)
	temp_card.queue_free()
	return new_card

func add_card(card):
	var new_card:Node = card_prefab.instantiate()
	add_child(new_card)
	new_card.set_stats(card.stats, card.base_stats)
	#Check if ingredient is already in inventory
	if new_card.stats.unlimited_uses:
		if ui != null:
			ui.update_slots()
		current_cards.append(new_card)
		on_add_card.emit(self,new_card)
		return new_card
	distribute_uses(new_card)
	on_add_card.emit(self,new_card)
	if ui != null:
		ui.update_slots()
	return new_card

func distribute_uses(card):
	if card == null or card.is_queued_for_deletion():
		return
	var duplicates:Array[Node] = []
	for i in current_cards:
		if i.base_stats == card.base_stats:
			
			duplicates.append(i)
	#find duplicate with less than 4 uses and assign more uses until the added card has no more
	if duplicates.size() !=0 and can_stack_uses:
		for i in duplicates:
			while i.stats.uses < 4 and card.stats.uses != 0:
				change_ingredient_uses(i, 1)
				change_ingredient_uses(card, -1)
			if card.stats.uses == 0 or card == null or card.is_queued_for_deletion():
				return
				
	current_cards.append(card)

func change_ingredient_uses(ingredient_card,amount):
	ingredient_card.stats.uses += amount
	if ingredient_card.stats.uses <= 0:
		ingredient_card.queue_free()

func check_can_drop(data):
	checking_drop.emit(self,data)
	#check for requirements
	if can_drop_card == false:
		can_drop_card = true
		return false
	#check abilities
	if abilities.on_try_add_ingredient_any_inventory(data) == false:
		return false
	#specific ingredient
	if cd_ingredients.size() != 0:
		for i in cd_ingredients:
			if i.stats.name == data.stats.name:
				return true
	#check if a tag is required
	if cd_tags.size() != 0:
		for i in cd_tags:
			if data.stats.tags.has(i):
				return true
	#check for rarity
	if cd_rarity.size() != 0:
		for i in cd_rarity:
			if data.stats.rarity.has(i):
				return true
	return true

func sort_inventory_by_name():
	current_cards.sort_custom(sort_by_name)
	if ui != null:
		ui.update_slots()
func sort_inventory_by_rarity():
	current_cards.sort_custom(sort_by_rarity)
	if ui != null:
		ui.update_slots()

func sort_by_rarity(a,b):
	if a.stats.rarity < b.stats.rarity:
		return true
	else:
		if a.stats.uses < b.stats.uses:
			return true
	return false
func sort_by_name(a, b): 
	return a.stats.name.naturalnocasecmp_to(b.stats.name) < 0

func reset_card_stats(card):
	#sets stats to be base
	card.reset_to_base_stats()
	ui.update_slots()

func reset_all_card_stats():
	for i in current_cards:
		reset_card_stats(i)

func set_ability_drag_preview(card):
	abilities.preview_card_abilities_add_dish(card, true)

func stop_ability_drag_preview(card):
	abilities.stop_preview_add_to_dish()
	
