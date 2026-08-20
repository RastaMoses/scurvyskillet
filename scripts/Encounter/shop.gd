extends Inventory
#PARAMS
@export var sell_items:Array[Resource]
@export var buy_button_sample:PackedScene
@export var rarity_prices:Array[int] = [1,3,5,10,20]
@export var morale_gain:int = 2
@export var morale_price:int = 5
#CACHED COMPS
@onready var player_inventory = get_node("/root/game/Player/Inventory")
@onready var map_node = get_parent()
@onready var buy_container = $BuyContainer
@onready var buy_round_button = $BuyRound/Button

func _ready() -> void:
	on_add_ingredient.connect(player_sell_ingredient)
	buy_round_button.pressed.connect(buy_morale)

#STATE
var buy_buttons:Array


func player_sell_ingredient(card):
	if card.stats.rarity == 0:
		player_inventory.change_money(player_inventory.current_money + rarity_prices[0])
	if card.stats.rarity == 1:
		player_inventory.change_money(player_inventory.current_money + rarity_prices[1])
	if card.stats.rarity == 2:
		player_inventory.change_money(player_inventory.current_money + rarity_prices[2])
	if card.stats.rarity == 3:
		player_inventory.change_money(player_inventory.current_money + rarity_prices[3])
	if card.stats.rarity == 4:
		player_inventory.change_money(player_inventory.current_money + rarity_prices[4])
	check_buttons_enabled()

func check_can_drop(data):
	if data.undroppable:
		return false
	else:
		return true

func buy_card(buy_button):
	if (buy_button.sell_item != null):
		player_inventory.add_ingredient(buy_button.sell_item)
		player_inventory.add_money(-buy_button.price)
	buy_button.sell_out()
	check_buttons_enabled()

func buy_morale():
	player_inventory.add_morale(morale_gain)
	player_inventory.add_money(-morale_price)
	buy_round_button.disabled = true
	
func check_buttons_enabled():
	for buy_button in buy_buttons:
		if buy_button.sold_out:
			return
		if buy_button.sell_item.price > player_inventory.current_money:
			buy_button.is_disabled(true)
		else:
			buy_button.is_disabled(false)

func populate_shop():
	for i in sell_items:
		var temp = buy_button_sample.instantiate()
		buy_container.add_child(temp)
		temp.set_item(i)
		buy_buttons.append(temp)
		temp.clicked.connect(buy_card)
	check_buttons_enabled()

func start():
	#display visuals
	populate_shop()
	player_inventory.ui.update_position(true)

func end():
	map_node.end_encounter()
	queue_free()


func _on_leave_button_pressed() -> void:
	end()
