
class_name Inventory
extends Node

@export var card_prefab:PackedScene
var current_ingredients: Array[Control]
@export var starting_ingredients: Array[Resource]
@export var ui:Control
@export var can_stack_uses:bool = true
@export_group("Can Drop Reqs")
@export var cd_tags:Array[String]
@export var cd_ingredients:Array[Resource]
@export var cd_rarity:int = -1 #-1 to disable
#CACHED COMPS
@onready var abilities = get_tree().get_first_node_in_group("ability_manager")
@onready var player_inventory = get_tree().get_first_node_in_group("player")
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
@onready var item_pool = get_tree().get_first_node_in_group("ingredient_pool")
#SIGNALS
signal on_add_ingredient(origin,card)
signal dropping_ingredient(origin, card)
signal on_remove_ingredient(origin,card)
signal checking_drop(origin,card)
signal destroying_ingredient(origin,card)
signal destroying_all(origin)
#STATE
var can_drop_card = true

func _ready() -> void:
	for i in starting_ingredients:
		add_ingredient(i)

func destroy_ingredient(card:Node):
	destroying_ingredient.emit(self,card)
	current_ingredients.erase(card)
	if ui != null:
		ui.update_slots()
	if card.get_parent() == self:
		card.queue_free()

func destroy_all_ingredients():
	destroying_all.emit(self)
	print(current_ingredients)
	for i in current_ingredients:
		i.queue_free()
	current_ingredients.clear()
	if ui != null:
		ui.update_slots()

func remove_ingredient(card):
	on_remove_ingredient.emit(self,card)
	change_ingredient_uses(card, -1)
	distribute_uses(card)
	if ui != null:
		ui.update_slots()

func drop_ingredient(card):
	dropping_ingredient.emit(self, card)
	add_ingredient(card.stats)
	player_inventory.remove_ingredient(card)

func add_ingredient(resource):
	var new_card:Node = card_prefab.instantiate()
	add_child(new_card)
	current_ingredients.append(new_card)
	new_card.set_stats(resource)
	#Check if ingredient is already in inventory
	if new_card.stats.unlimited_uses:
		current_ingredients.append(new_card)
		on_add_ingredient.emit(self,new_card)
		if ui != null:
			ui.update_slots()
		return
	distribute_uses(new_card)
	on_add_ingredient.emit(self,new_card)
	if ui != null:
		ui.update_slots()

func distribute_uses(card):
	if card == null:
		return
	current_ingredients.erase(card)
	var duplicates:Array[Node]
	for i in current_ingredients:
		if i.stats.name == card.stats.name:
			duplicates.append(i)
	#find duplicate with less than 4 uses and assign more uses until the added card has no more
	if duplicates.size() !=0 and can_stack_uses:
		for i in duplicates:	
			while i.stats.uses < 4 and card.stats.uses != 0:
				change_ingredient_uses(i, 1)
				change_ingredient_uses(card, -1)
			if card.stats.uses == 0 or card == null:
				if ui != null:
					ui.update_slots()
				return
	current_ingredients.append(card)

func change_ingredient_uses(ingredient_card,amount):
	if ingredient_card.stats.unlimited_uses:
		return
	ingredient_card.stats.uses += amount
	if ingredient_card.stats.uses <= 0:
		destroy_ingredient(ingredient_card)

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
	if cd_rarity != -1:
		if data.stats.rarity == cd_rarity:
			return true
		else:
			return false
	return true
