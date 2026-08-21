extends Inventory
#PARAMS
#@export var specific_sell_items:Array[Resource]
#@export var random_ingredient_amount:int = 1


@export var buy_button_sample:PackedScene
@export var rarity_prices:Array[int] = [1,2,3,5]
@export var hidden_item_price:int = 1
@export var morale_gain:int = 2
@export var morale_price:int = 3
#CACHED COMPS
@onready var map_node = get_parent()
@onready var buy_container = $UI/BuyButtons
@onready var buy_round_button = $UI/BuyRound/Button
@onready var shop_ui = $UI

#STATE
var morale_sold_out = false

func _ready() -> void:
	checking_drop.connect(on_checking_drop)
	dropping_ingredient.connect(player_sell_ingredient)
	buy_round_button.pressed.connect(buy_morale)
	buy_buttons = buy_container.get_children()
	for i in buy_buttons:
		i.shop = self
#STATE
var buy_buttons:Array

func player_sell_ingredient(origin,card):
	if origin != self:
		return
	player_inventory.add_money(rarity_prices[card.stats.rarity])
	player_inventory.remove_ingredient(card)
	check_buttons_enabled()

func on_checking_drop(origin):
	if origin != self:
		return
	shop_ui.toggle_sell_highlight(true)

func buy_card(buy_button):
	if buy_button.sell_card != null:
		player_inventory.add_ingredient(buy_button.sell_card.stats)
		destroy_ingredient(buy_button.sell_card)
		player_inventory.add_money(-buy_button.price)
	buy_button.sell_out()
	check_buttons_enabled()

func buy_morale():
	player_inventory.add_morale(morale_gain)
	player_inventory.add_money(-morale_price)
	shop_ui.toggle_buy_round_foam(false)
	buy_round_button.disabled = true
	morale_sold_out = true
	shop_ui.hide_buy_round_highlight()
	
func check_buttons_enabled():
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
	check_buttons_enabled()

func get_card_price(card):
	return rarity_prices[card.stats.rarity]

func start():
	#display visuals
	populate_shop()
	player_inventory.ui.update_position(true)

func end():
	map_node.end_encounter()
	queue_free()

func set_large_view_card(card):
	player_inventory.ui.toggle_large_view(card)

func _on_leave_button_pressed() -> void:
	end()
