extends Node
#STATE
@export_group("Leftover")
@export var leftover_bone:PackedScene

#CACHED COMPS
@onready var inventory = get_node("/root/game/Player/Inventory")
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
		inventory.instantiate_card_from_resource(leftover_bone)

func on_try_add_ingredient(card):
	var can_add = true
	#Spice
	if card.stats.abilities.has("spice"):
		for i in spice_list:
			if i == card.stats:
				return false
	return can_add
