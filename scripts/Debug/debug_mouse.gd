extends Node


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var hovered := get_viewport().gui_get_hovered_control()
	if hovered:
		print("Hovered control: ", hovered.get_path())
		print("Type: ", hovered.get_class())
		print("Mouse filter: ", hovered.mouse_filter)
