extends Control
@export var hide_item:bool = false
@export var specific_item:Resource
@export_subgroup("Random Item Reqs")
@export var and_req:bool = false
@export_enum("common", "uncommon", "rare", "legendary") var req_rarity:Array[int]
@export_enum("tag1", "tag2", "tag3", "tag4") var req_tag:Array[String]
@export_enum("seasoning", "ability2", "leftover", "richard") var req_ability:Array[String]

@onready var button = $Button
@onready var button_highlight = $Button/Highlight
@onready var ui_slot = $ItemVisuals/InventoryUISlot
@onready var hidden_icon = $ItemVisuals/HiddenIcon
@onready var price_text = $ItemVisuals/PriceText
@onready var item_visuals = $ItemVisuals
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
	var rand = item_pool.get_random_ingredient(and_req,req_tag,req_ability,req_rarity)
	set_item(rand)

func set_item(resource):
	sell_card = shop.add_ingredient(resource)
	toggle_item_icon(true)
	if !hide_item:
		price = shop.get_card_price(sell_card)
		ui_slot.visible = true
		hidden_icon.visible = false
	else:
		ui_slot.visible = false
		hidden_icon.visible = true
		price = shop.hidden_item_price
	
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
