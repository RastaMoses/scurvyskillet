extends Control
@export var remove_from_player:bool = true
@export var parent_inventory:Inventory

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return parent_inventory.check_can_drop(data.card)
	
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	parent_inventory.drop_ingredient(data.card)
		
