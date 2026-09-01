class_name BuyButton
extends Control
@export var hide_item:bool = false
@export var specific_item:Ingredient
@export_group("Random Item")
@export var and_req:bool = false
@export var req_rarity:Array[GlobalEnums.Rarity]
@export var req_tag:Array[GlobalEnums.Tags]
@export var req_ability:Array[Ability]
@export_subgroup("Random Rarity Chances")
@export var common_chance:int = 10
@export var uncommon_chance:int = 10
@export var rare_chance:int = 4
@export var legendary_chance:int = 1
@export_subgroup("Random Rarity Max Spawn Uses")
@export var common_uses:int = 3
@export var uncommon_uses:int = 1
@export var rare_uses:int = 1
@export var legendary_uses:int = 1



@onready var button = $Button
@onready var button_highlight = $Button/Highlight
@onready var ui_slot = $ItemVisuals/InventoryUISlot
@onready var hidden_icon = $ItemVisuals/HiddenIcon
@onready var price_text = $ItemVisuals/PriceText
@onready var item_visuals = $ItemVisuals
@onready var random = RandomNumberGenerator.new()
@onready var item_pool = get_tree().get_first_node_in_group("ingredient_pool")

var sell_card
var sold_out = false
var can_buy = true
var price:int
var shop

func populate():
	if specific_item != null:
		set_item(specific_item)
	else:
		set_random_item()

func set_random_item():
	var rarity_req:Array[GlobalEnums.Rarity]
	if req_rarity.is_empty():
		var rand_rar_chances:Array[GlobalEnums.Rarity]
		for i in common_chance:
			rand_rar_chances.append(GlobalEnums.Rarity.COMMON)
		for i in uncommon_chance:
			rand_rar_chances.append(GlobalEnums.Rarity.UNCOMMON)
		for i in rare_chance:
			rand_rar_chances.append(GlobalEnums.Rarity.RARE)
		for i in legendary_chance:
			rand_rar_chances.append(GlobalEnums.Rarity.LEGENDARY)
		var rand_rar:GlobalEnums.Rarity = rand_rar_chances[random.randi_range(0, rand_rar_chances.size()-1)]
		rarity_req.append(rand_rar)
	else:
		rarity_req = req_rarity
	var rand_ingr = item_pool.get_random_ingredient(and_req,req_tag,req_ability,rarity_req)
	set_item(rand_ingr)

func set_card_uses():
	match sell_card.committed_stats.rarity:
		GlobalEnums.Rarity.COMMON:
			var rand = random.randi_range(1,common_uses)
			sell_card.committed_stats.uses = rand
		GlobalEnums.Rarity.UNCOMMON:
			var rand = random.randi_range(1,uncommon_uses)
			sell_card.committed_stats.uses = rand
		GlobalEnums.Rarity.RARE:
			var rand = random.randi_range(1,rare_uses)
			sell_card.committed_stats.uses = rand
		GlobalEnums.Rarity.LEGENDARY:
			var rand = random.randi_range(1,legendary_uses)
			sell_card.committed_stats.uses = rand
func set_item(resource):
	sell_card = shop.instantiate_card_and_add(resource)
	toggle_item_icon(true)
	if !hide_item:
		price = shop.get_card_price(sell_card)
		ui_slot.visible = true
		hidden_icon.visible = false
	else:
		ui_slot.visible = false
		hidden_icon.visible = true
		price = shop.hidden_item_price
	set_card_uses()
	ui_slot.update(sell_card)
	can_buy = true
	#set ui slot large view button to work with player inventory ui
	
	price_text.text = str(price)
	
func sell_out():
	sold_out = true
	set_clickable(false)
	toggle_item_icon(false)

func set_clickable(value):
	can_buy = value
	if !value:
		button_highlight.visible = false

func toggle_item_icon(value):
	item_visuals.visible = value

func large_view_pressed():
	shop.set_large_view_card(sell_card)

func _on_button_mouse_entered() -> void:
	if !can_buy:
		return
	button_highlight.visible = true

func _on_button_mouse_exited() -> void:
	button_highlight.visible = false

#check left or right click
func _on_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				# left button clicked
				if !can_buy:
					return
				shop.buy_card(self)
			MOUSE_BUTTON_RIGHT:
				if sold_out or hide_item:
					return
				# right button clicked
				large_view_pressed()
