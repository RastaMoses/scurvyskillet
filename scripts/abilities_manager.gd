extends Node
#STATE
@export_group("Leftovers")
@export var leftovers_bone:Resource

#CACHED COMPS
@onready var player_inventory = get_tree().get_first_node_in_group("player")
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
#STATE
@onready var seasoning_list:Array[String]

var can_add_any_ingredients_to_dish = true
#SIGNALS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func on_dish_complete():
	#reset all dish specific states
	seasoning_list.clear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_challenge_end():
	can_add_any_ingredients_to_dish = true

func on_dice_roll(card):
	pass

func on_die_roll(card):
	pass

func on_ingredient_add_to_dish(card, dish): #before adding own stats to dish
	
	if card.stats.abilities.has("dessert"):
		can_add_any_ingredients_to_dish = false
	
	#Spice
	if card.stats.abilities.has("seasoning"):
		seasoning_list.append(card.stats.name)
	#Leftovers
	#Bone Leftovers
	if card.stats.abilities.has("leftover_bone"):
		player_inventory.add_ingredient(leftovers_bone)
	
	#if all flavours are present
	if dish.sweet > 0 and dish.spicy > 0 and dish.hearty > 0 and dish.fresh > 0:
		if card.stats.abilities.has("rainbow_cake"):
			card.nutrition += 5


func on_try_add_ingredient_any_inventory(card):
	var can_add = true
	if card.stats.abilities.has("undroppable"):
		can_add = false
	
	return can_add

func on_try_add_to_dish(card):
	if seasoning_list.has(card.stats.name):
		return false
	
	return true
