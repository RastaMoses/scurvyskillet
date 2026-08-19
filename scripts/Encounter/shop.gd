extends Control
#PARAMS
@export var sell_items:Array[Resource]
@export var buy_button_sample:PackedScene
@export var rarity_prices:Array[int] = [1,3,5,10,20]
#CACHED COMPS
@onready var player_inventory = get_node("/root/root/Player/Inventory")
@onready var map_node = get_parent()
@onready var buy_container = $BuyContainer


#STATE
var buy_buttons:Array
var encounter_type = "shop"

func add_ingredient(ingredient):
	player_sell_ingredient(ingredient.rarity)
	player_inventory.destroy_ingredient(ingredient)

func player_sell_ingredient(rarity):
	if rarity == 0:
		player_inventory.change_money(player_inventory.current_money + rarity_prices[0])
	if rarity == 1:
		player_inventory.change_money(player_inventory.current_money + rarity_prices[1])
	if rarity == 2:
		player_inventory.change_money(player_inventory.current_money + rarity_prices[2])
	if rarity == 3:
		player_inventory.change_money(player_inventory.current_money + rarity_prices[3])
	if rarity == 4:
		player_inventory.change_money(player_inventory.current_money + rarity_prices[4])
	check_buttons_enabled()

func check_can_drop(data):
	if data.undroppable:
		return false
	else:
		return true

func buy(buy_button):
	if (buy_button.sell_item.ingredient != null):
		player_inventory.instantiate_ingredient(buy_button.sell_item.ingredient)
	player_inventory.change_morale(player_inventory.current_morale + buy_button.sell_item.morale_gain)
	player_inventory.change_money(player_inventory.current_money - buy_button.sell_item.price)
	sell_items.erase(buy_button.sell_item)
	buy_buttons.erase(buy_button)
	buy_button.queue_free()
	check_buttons_enabled()
	
func check_buttons_enabled():
	for buy_button in buy_buttons:
		if buy_button.sell_item.price > player_inventory.current_money:
			buy_button.is_disabled(true)
		else:
			buy_button.is_disabled(false)

func populate_shop():
	for i in sell_items:
		var temp = buy_button_sample.instantiate()
		buy_container.add_child(temp)
		temp.sell_item = i
		buy_buttons.append(temp)
		temp.clicked.connect(buy)
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
