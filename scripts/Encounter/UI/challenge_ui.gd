extends Control
@onready var reset = $Reset
@onready var reset_button = $Reset/reset_button
@onready var reset_button_arrow = $Reset/reset_bag_arrow
@onready var dish_roll_button = $Complete/roll_dish_button
@onready var ladle_hover = $Complete/ladle_hover
@onready var ladle_highlight = $Complete/highlight
@onready var des_vbox = $description/ScrollContainer/VBoxContainer

var disabled = false

func _on_reset_button_mouse_entered() -> void:
	if disabled:
		return
	reset_button_arrow.visible = true

func _on_reset_button_mouse_exited() -> void:
	if disabled:
		return
	reset_button_arrow.visible = false

func _on_roll_dish_button_mouse_entered() -> void:
	if disabled:
		return
	ladle_hover.visible = true
	ladle_highlight.visible = true

func _on_roll_dish_button_mouse_exited() -> void:
	if disabled:
		return
	ladle_hover.visible = false
	ladle_highlight.visible = false

func toggle_disable_buttons(value):
	disabled = value
	dish_roll_button.disabled = value
	reset_button.disabled = value
	if !value:
		dish_roll_button.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
		reset_button.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	else:
		dish_roll_button.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
		reset_button.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
	reset_button_arrow.visible = false
	ladle_hover.visible = false
	ladle_highlight.visible = false
	
	
