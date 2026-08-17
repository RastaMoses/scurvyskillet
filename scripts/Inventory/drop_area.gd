extends Control

@onready var dish = get_parent()

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	dish.add_ingredient(data.ingredient)
	data.ingredient = null
