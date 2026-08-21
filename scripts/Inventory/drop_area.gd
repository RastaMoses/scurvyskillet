extends Control
@export var remove_from_player:bool = true
@onready var parent = get_parent()

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return parent.check_can_drop(data.card)
	
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	get_parent().drop_ingredient(data.card)
		
