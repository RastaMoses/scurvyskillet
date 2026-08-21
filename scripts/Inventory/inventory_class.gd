
class_name Inventory
extends Node

@export var card_prefab:PackedScene
var current_ingredients: Array[Node]
@export var starting_ingredients: Array[Resource]
@export var ui:Control
@export var can_stack_uses:bool = true
@export_group("Can Drop Reqs")
@export var cd_tags:Array[String]
@export var cd_ingredients:Array[Resource]
@export var cd_rarity:int = -1 #-1 to disable
#CACHED COMPS
@onready var abilities = get_node("/root/game/Player/Abilities")
@onready var item_pool = get_node("/root/game/IngredientPool")
@onready var player_inventory = get_node("/root/game/Player/Inventory")
#SIGNALS
signal on_add_ingredient(origin,card)
signal on_remove_ingredient(origin,card)
signal checking_drop(origin,card)
signal removing_all(origin)
signal destroying_ingredient(origin,card)
signal destroying_all(origin)
#STATE
var can_drop_card = true

func _ready() -> void:
	for i in starting_ingredients:
		instantiate_card_from_resource(i)

func destroy_ingredient(card):
	destroying_ingredient.emit(self,card)
	current_ingredients.erase(card)
	if ui != null:
		ui.update_slots()
	if card.get_parent() == self:
		card.queue_free()
func destroy_all_ingredients():
	destroying_all.emit(self)
	for i in current_ingredients:
		destroy_ingredient(i)

func remove_ingredient(card):
	on_remove_ingredient.emit(self,card)
	change_ingredient_uses(card, -1)
	if ui != null:
		ui.update_slots()

	
func instantiate_card_from_resource(ingredient_resource:Resource):
	var card:Node = card_prefab.instantiate()
	add_child(card)
	card.set_stats(ingredient_resource)
	add_ingredient(card)
	return card

func add_ingredient(card:Node):
	var new_card = card.duplicate(DUPLICATE_DEFAULT | DUPLICATE_INTERNAL_STATE | DUPLICATE_SCRIPTS)
	add_child(new_card)
	print(new_card)
	on_add_ingredient.emit(self,new_card)
	#Check if ingredient is already in inventory
	if new_card.stats.unlimited_uses:
		current_ingredients.append(new_card)
		if ui != null:
			ui.update_slots()
		return
	var duplicates:Array[Node]
	for i in current_ingredients:
		if i.stats == new_card.stats:
			duplicates.append(i)
	#find duplicate with less than 4 uses and assign more uses until the added card has no more
	if duplicates.size() !=0 and can_stack_uses:
		for i in duplicates:
			while i.uses < 4 and new_card.uses != 0:
				change_ingredient_uses(i, 1)
				change_ingredient_uses(new_card, -1)
			if new_card.uses == 0 or new_card == null:
				if ui != null:
					ui.update_slots()
				return
	current_ingredients.append(new_card)
	if ui != null:
		ui.update_slots()

func change_ingredient_uses(ingredient_card,amount):
	if ingredient_card.stats.unlimited_uses:
		return
	ingredient_card.uses += amount
	if ingredient_card.uses <= 0:
		destroy_ingredient(ingredient_card)

func check_can_drop(data):
	checking_drop.emit(self,data)
	#check for requirements
	if can_drop_card == false:
		can_drop_card = true
		return false
	#check abilities
	if abilities.on_try_add_ingredient(data) == false:
		return false
	#specific ingredient
	if cd_ingredients.size() != 0:
		if cd_ingredients.has(data.stats):
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
