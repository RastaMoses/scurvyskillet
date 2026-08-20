extends Control

@onready var parent = get_parent()

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return parent.check_can_drop(data.ingredient)
	
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	parent.add_ingredient(data.ingredient)
