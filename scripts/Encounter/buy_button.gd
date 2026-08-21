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
@onready var ui_slot = $InventoryUISlot
@onready var hidden_icon = $HiddenIcon
@onready var price_text = $Button/PriceText
@onready var item_pool = get_tree().get_first_node_in_group("ingredient_pool")

var sell_card
var sold_out = false
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
	sell_card = shop.instantiate_card_from_resource(resource)
	
	if !hide_item:
		price = shop.get_card_price(sell_card)
		ui_slot.visible = true
		hidden_icon.visible = false
	else:
		ui_slot.visible = false
		hidden_icon.visible = true
		price = shop.hidden_item_price
	
	ui_slot.update(sell_card)
	#set ui slot large view button to work with player inventory ui
	
	price_text.text = str(price)
	
	
func sell_out():
	sold_out = true
	ui_slot.visible = false
	is_disabled(true)


func is_disabled(info):
	button.disabled = info

func large_view_pressed():
	shop.set_large_view_card(sell_card)

func _on_button_mouse_entered() -> void:
	button_highlight.visible = true


func _on_button_mouse_exited() -> void:
	button_highlight.visible = false

#check left or right click
func _on_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				# left button clicked
				shop.buy_card(self)
			MOUSE_BUTTON_RIGHT:
				# right button clicked
				large_view_pressed()
