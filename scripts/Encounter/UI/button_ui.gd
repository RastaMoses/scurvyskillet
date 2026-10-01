class_name ButtonUI
extends Control
@export_group("Display")
@export var highlight:Control
@export var anti_highlight:Control
@export var text_label:RichTextLabel
@export var button:Button
#Signals
signal start_hover
signal stop_hover
signal left_clicked
signal right_clicked

#State
var mouse_hovering:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	toggle_highlight(false)
	button.gui_input.connect(_gui_input)
	button.mouse_entered.connect(_on_mouse_enter)
	button.mouse_exited.connect(_on_mouse_exit)

func _gui_input(event: InputEvent) -> void:
	if button.disabled:
		return
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				#left clicked
				left_clicked.emit()
			MOUSE_BUTTON_RIGHT:
				# right clicked
				right_clicked.emit()

func _on_mouse_enter():
	mouse_hovering = true
	toggle_highlight(true)
	start_hover.emit()
func _on_mouse_exit():
	mouse_hovering = false
	toggle_highlight(false)
	stop_hover.emit()

func toggle_disabled(value:bool):
	toggle_mouse_filter(!value)
	button.disabled = value
	if mouse_hovering:
		toggle_highlight(!value)
		mouse_hovering = !value

func toggle_mouse_filter(value:bool):
	if value:
		button.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	else:
		button.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE

func toggle_highlight(value:bool):
	if highlight != null:
		highlight.visible = value
	if anti_highlight != null:
		anti_highlight.visible = !value

func set_text(text):
	text_label.text = text
