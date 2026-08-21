extends Node
#STATE
@export_group("Leftovers")
@export var leftovers_bone:PackedScene

#CACHED COMPS
@onready var player_inventory = get_tree().get_first_node_in_group("player")
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
#STATE
@onready var spice_list:Array[Resource]

#SIGNALS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func on_dish_complete():
	#reset all dish specific states
	spice_list.clear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_dice_roll(ingredient):
	pass

func on_die_roll(ingredient):
	pass

func on_ingredient_add_to_dish(card):
	#Spice
	if card.stats.abilities.has("spice"):
		spice_list.append(card.stats)
	#Leftovers
	#Bone Leftovers
	if card.stats.abilities.has("leftover_bone"):
		player_inventory.instantiate_card_from_resource(leftovers_bone)
	

func on_try_add_ingredient(card):
	var can_add = true
	if card.stats.abilities.has("undroppable"):
		can_add = false
	return can_add

func on_try_add_to_dish(card):
	if spice_list.has(card.stats):
		return false
	return true
