extends Node
#STATE
@export_group("Leftover")
@export var leftover_bone:PackedScene

#CACHED COMPS
@onready var inventory = get_node("/root/root/Player/Inventory")
#STATE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_dice_roll(ingredient):
	pass

func on_die_roll(ingredient):
	pass

func on_ingredient_add(ingredient):
	#Leftovers
	#Bone Leftovers
	if ingredient.abilities.has("leftover_bone"):
		inventory.instantiate_ingredient(leftover_bone)
	
