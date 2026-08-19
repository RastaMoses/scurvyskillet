extends Control
var sell_item:Resource
signal clicked(buy_button)

func _on_button_pressed() -> void:
	clicked.emit(self)

func is_disabled(info):
	$Button.disabled = info
