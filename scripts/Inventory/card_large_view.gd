extends Control
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
@onready var button = $Button
@onready var slot = $InventoryUILarge
@onready var bg = $ButtonBG
@export var bg_fade_speed = 1
@export var slot_positions:Array[Vector2]
@export var hover_large_view_time:float = 0.4
var ui
var hovering:bool = false
var hover_card:Card
var hover_large_view:bool = false
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

func toggle_large_view(card, value):
	if not value:
		event_manager.large_view_toggle(false)
		button.visible = false
		slot.visible = false
		bg.start_fade(-bg_fade_speed)
		large_view_active = false
	else:
		event_manager.large_view_toggle(true)
		button.visible = true
		slot.visible = true
		bg.start_fade(bg_fade_speed)
		if card != null:
			slot.update(card)
		large_view_active = true

func button_pressed(card = null, right_click = true):
	if large_view_active:
		if right_click:
			if slot.card == card and not hover_large_view:
				toggle_large_view(null, false)
			else:
				set_new_large_view(card)
		else:
			toggle_large_view(null, false)
	else:
		if right_click:
			toggle_large_view(card, true)
	hover_large_view = false
func cancel_large_view_pressed():
	if large_view_active:
		event_manager.large_view_toggle(false)
		toggle_large_view(null, false)

func set_new_large_view(card):
	slot.update(card)

func reset_large_view():
	if button == null:
		return
	bg.stop_fade()
	slot.visible = false
	button.visible = false
	if (large_view_active):
		toggle_large_view(null, false)
	large_view_active = false

func set_slot_position(value):
	slot.position = slot_positions[value]

func on_start_hover(slot):
	if not slot.large_view_clickable:
		return
	hovering = true
	hover_card = slot.card
	await get_tree().create_timer(hover_large_view_time).timeout
	if hovering and not large_view_active:
		toggle_large_view(hover_card, true)
		hover_large_view = true
func on_stop_hover(slot):
	if not slot.large_view_clickable:
		return
	hovering = false
	if hover_large_view:
		hover_large_view = false
		toggle_large_view(null, false)
