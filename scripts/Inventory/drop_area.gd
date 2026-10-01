class_name DropArea
extends Control
@export var remove_from_player:bool = true
@export var parent_inventory:Inventory
@export var highlight:Control
@export var bg:Control
@export var text_label:RichTextLabel


var disabled:bool = false

func _ready() -> void:
	mouse_exited.connect(mouse_exit)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if disabled:
		return false
	var can_drop = parent_inventory.check_can_drop(data.card)
	toggle_highlight(can_drop)
	return can_drop
	
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	parent_inventory.drop_ingredient(data.card)
	toggle_highlight(false)

func toggle_disabled(value:bool):
	disabled = value
	toggle_highlight(!value)
	toggle_mouse_filter(!value)

func toggle_visible(value):
	toggle_disabled(!value)
	visible = value

func toggle_highlight(value):
	if highlight != null:
		highlight.visible = value

func toggle_mouse_filter(value:bool):
	if value:
		mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	else:
		mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE

func set_text(text):
	if text_label != null:
		text_label.text = text

func mouse_exit():
	toggle_highlight(false)
