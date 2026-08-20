extends Node
#STATE
@export_group("Leftover")
@export var leftover_bone:PackedScene

#CACHED COMPS
@onready var inventory = get_node("/root/root/Player/Inventory")
#STATE
@onready var spice_list:Array[Node] = []

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

func on_ingredient_add_to_dish(ingredient):
	#Spice
	if ingredient.abilities.has("spice"):
		spice_list.append(ingredient)
	#Leftovers
	#Bone Leftovers
	if ingredient.abilities.has("leftover_bone"):
		inventory.instantiate_ingredient(leftover_bone)

func on_try_add_ingredient(ingredient):
	var can_add = true
	#Spice
	if ingredient.abilities.has("spice"):
		for i in spice_list:
			if i.get_ingredient_name() == ingredient.get_ingredient_name():
				return false
	return can_add
