class_name Shop
extends Inventory
#PARAMS
#@export var specific_sell_items:Array[Resource]
#@export var random_ingredient_amount:int = 1
@export var buy_button_sample:PackedScene
@export var rarity_prices:Array[int] = [1,2,3,5]
@export var hidden_item_price:int = 1
@export var morale_gain:int = 2
@export var morale_price:int = 3
@export_group("Nodes")
@export var buy_buttons:Array[BuyButton]
@export var shop_ui:ShopUI


#CACHED COMPS
@onready var map_node = get_parent()

#STATE
var morale_sold_out = false
var interactable = true

func _ready() -> void:
	event_manager.large_view_toggled.connect(toggle_large_view)
	init_inventory()
	checking_drop.connect(on_checking_drop)
	dropping_ingredient.connect(player_sell_ingredient)
	for buy_button in buy_buttons:
		buy_button.shop = self

func player_sell_ingredient(origin,card):
	if origin != self:
		return
	player_inventory.add_money(rarity_prices[card.stats.rarity])
	check_buy_buttons_available()

func on_checking_drop(origin, data):
	if origin != self:
		return
	if !interactable:
		can_drop_card = false
		return

func buy_card(buy_button):
	if buy_button.sell_card != null:
		player_inventory.add_card(buy_button.sell_card)
		destroy_ingredient(buy_button.sell_card)
		player_inventory.add_money(-buy_button.price)
	buy_button.sell_out()
	check_buy_buttons_available()

func buy_morale():
	player_inventory.add_morale(morale_gain)
	player_inventory.add_money(-morale_price)
	shop_ui.toggle_buy_round_foam(false)
	shop_ui.buy_round_button.toggle_disabled(true)
	morale_sold_out = true
	
func check_buy_buttons_available():
	for buy_button in buy_buttons:
		if buy_button.sold_out:
			return
		if buy_button.price > player_inventory.current_money:
			buy_button.can_buy = false
		else:
			buy_button.can_buy = true

func populate_shop():
	for i in buy_buttons:
		i.populate()
	check_buy_buttons_available()

func get_card_price(card):
	return rarity_prices[card.stats.rarity]

func start():
	#display visuals
	populate_shop()

func end():
	map_node.end_encounter()
	queue_free()

func toggle_large_view(value):
	interactable = !value
	shop_ui.toggle_interactable()
