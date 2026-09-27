extends Control
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
@onready var button = $Button
@onready var slot = $InventoryUILarge
@onready var bg = $ButtonBG
@export var bg_fade_speed = 1
var ui

var large_view_active:bool = false
# Called when the node enters the scene tree for the first time.
func init_large_view(ui_node) -> void:
	ui = ui_node
	#connect large view buttons
	if button != null:
		button.pressed.connect(cancel_large_view_pressed)
	slot.init_slot(ui)
	slot.large_view_clicked.connect(button_pressed)
	reset_large_view()

func toggle_large_view(card):
	if large_view_active:
		
		button.visible = false
		slot.visible = false
		bg.start_fade(-bg_fade_speed)
		large_view_active = false
	else:
		
		button.visible = true
		slot.visible = true
		bg.start_fade(bg_fade_speed)
		if card != null:
			slot.update(card)
		large_view_active = true

func button_pressed(card = null, right_click = true):
	if large_view_active:
		if right_click:
			if slot.card == card:
				event_manager.large_view_toggle(false)
				toggle_large_view(null)
			else:
				set_new_large_view(card)
		else:
			event_manager.large_view_toggle(false)
			toggle_large_view(null)
	else:
		if right_click:
			event_manager.large_view_toggle(true)
			toggle_large_view(card)

func cancel_large_view_pressed():
	if large_view_active:
		event_manager.large_view_toggle(false)
		toggle_large_view(null)

func set_new_large_view(card):
	slot.update(card)

func reset_large_view():
	if button == null:
		return
	bg.stop_fade()
	slot.visible = false
	button.visible = false
	if (large_view_active):
		toggle_large_view(null)
	large_view_active = false
