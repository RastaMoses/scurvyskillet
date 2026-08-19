extends Control
@onready var reset = $Reset
@onready var reset_button_arrow = $Reset/reset_bag_arrow
@onready var ladle_hover = $Complete/ladle_hover

func _on_reset_button_mouse_entered() -> void:
	reset_button_arrow.visible = true

func _on_reset_button_mouse_exited() -> void:
	reset_button_arrow.visible = false


func _on_roll_dish_button_mouse_entered() -> void:
	ladle_hover.visible = true


func _on_roll_dish_button_mouse_exited() -> void:
	ladle_hover.visible = false
