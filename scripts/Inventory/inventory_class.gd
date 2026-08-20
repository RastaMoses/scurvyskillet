
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
@export var cd_rarity:int = -1
#CACHED COMPS
@onready var abilities = get_node("/root/game/Player/Abilities")
#SIGNALS
signal on_add_ingredient(card)
signal on_remove_ingredient(card)
#STATE

func _ready() -> void:
	for i in starting_ingredients:
		instantiate_card_from_resource(i)

func destroy_ingredient(card):
	current_ingredients.erase(card)
	if ui != null:
		ui.update_slots()
	if card.get_parent() == self:
		card.queue_free()

func remove_ingredient(card):
	on_remove_ingredient.emit(card)
	change_ingredient_uses(card, -1)
	if ui != null:
		ui.update_slots()

func instantiate_card_from_resource(ingredient_resource:Resource):
	var card:Node = card_prefab.instantiate()
	add_child(card)
	card.set_stats(ingredient_resource)
	add_ingredient(card)

func add_ingredient(card:Node):
	on_add_ingredient.emit(card)
	card.reparent(self)
	#Check if ingredient is already in inventory
	if card.stats.unlimited_uses:
		current_ingredients.push_front(card)
		if ui != null:
			ui.update_slots()
		return
	var duplicates:Array[Node]
	for i in current_ingredients:
		if i.stats == card.stats:
			duplicates.append(i)
	#find duplicate with less than 4 uses and assign more uses until the added card has no more
	if duplicates.size() !=0 and can_stack_uses:
		for i in duplicates:
			while i.uses < 4 and card.uses != 0:
				change_ingredient_uses(i, 1)
				change_ingredient_uses(card, -1)
			if card.uses == 0 or card == null:
				if ui != null:
					ui.update_slots()
				return
	current_ingredients.push_front(card)
	if ui != null:
		ui.update_slots()

func change_ingredient_uses(ingredient_card,amount):
	if ingredient_card.stats.unlimited_uses:
		return
	ingredient_card.uses += amount
	if ingredient_card.uses <= 0:
		destroy_ingredient(ingredient_card)

func check_can_drop(data):
	#check for requirements
	#check abilities
	if abilities.on_try_add_ingredient(data) == false:
		return false
	#undroppable items (curses)
	if data.stats.undroppable:
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
