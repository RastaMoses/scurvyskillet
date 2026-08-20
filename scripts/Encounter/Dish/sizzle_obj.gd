extends AnimatedSprite2D

@export var pixel_multiple: int = 8  # Change to 4, 8, etc. as needed

	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var raw_position: Vector2 = global_position 
	# Snap to multiples of your chosen pixel size
	global_position = Vector2(
		round(raw_position.x / pixel_multiple) * pixel_multiple,
		round(raw_position.y / pixel_multiple) * pixel_multiple
	)
	await get_tree().process_frame
	
	# Snap 2D rotation degrees to the nearest 90-degree increment
	#global_rotation_degrees = snappedf(global_rotation_degrees, 90.0)
	play("sizzle")


func _on_animation_finished() -> void:
	queue_free()
