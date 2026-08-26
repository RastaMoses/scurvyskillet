extends Node

#PARAMS
#CACHED COMPS
@onready var player_inventory = get_tree().get_first_node_in_group("player")
@onready var item_pool = get_tree().get_first_node_in_group("ingredient_pool")
@onready var ability_manager = get_tree().get_first_node_in_group("ability_manager")
@onready var map_loader = get_tree().get_first_node_in_group("map_loader")
#SIGNALS
signal on_encounter_end
signal on_encounter_start
signal on_inventory_update
signal on_dish_finish_anim_done
signal starting_game
#STATE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func start_game():
	starting_game.emit()
	player_inventory.ui.open()
	map_loader.start_game()

func encounter_load():
	player_inventory.ui.open()

func encounter_start():
	#disable map interface
	#set bg
	on_encounter_start.emit()
	
func encounter_end():
	#perishables ability
	on_encounter_end.emit()
	player_inventory.ui.open()
	

func dish_complete(dish):
	pass

func add_to_dish(ingredient):
	pass

	
func update_inventory_position():
	on_inventory_update.emit()

func dish_finish_animation_done():
	on_dish_finish_anim_done.emit()
