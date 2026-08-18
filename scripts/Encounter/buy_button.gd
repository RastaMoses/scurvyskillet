extends Control
var sell_item:Resource

func _on_button_pressed() -> void:
	pass # Replace with function body.

func is_disabled(info):
	$Button.disabled = info
