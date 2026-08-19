extends Control
@onready var reset = $Reset
@onready var reset_button_arrow = $Reset/reset_bag_arrow

func _on_reset_button_mouse_entered() -> void:
	reset_button_arrow.visible = true

func _on_reset_button_mouse_exited() -> void:
	reset_button_arrow.visible = false
