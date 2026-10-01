extends Control
@export_subgroup("Flavour Display")
@export var plate_anim_speed:float = 1

#Onready
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
#Challenge
@onready var challenge = get_parent()

#Description
@onready var des_vbox = $description/ScrollContainer/VBoxContainer
@onready var inventory_display = $InventoryUI
#Result Screen
@onready var result_stats_display = $ResultScreen/ResultPanel/Stats
@onready var result_end_button = $ResultScreen/ResultPanel/EndButton
@onready var result_toggle_panel_button = $ResultScreen/ToggleResultButton
@onready var result_screen = $ResultScreen
@onready var result_panel = $ResultScreen/ResultPanel
@onready var result_text_vbox = $ResultScreen/ResultPanel/ScrollContainer/VBoxContainer
@onready var result_text_combination_box = $ResultScreen/ResultPanel/ScrollContainer/VBoxContainer/combination_text
#Dish
@onready var dish_stats_display = $Dish/Stats
@onready var pan_highlight = $Dish/Pan/highlight
@onready var drop_area = $Dish/DropArea
@onready var reset_button = $Dish/ResetButton
@onready var finish_dish_button = $Dish/FinishButton
@onready var plates = $Dish/PlatesDisplay/plates.get_children()
@onready var plates_shadow = $Dish/PlatesDisplay/shadow
#Signals
signal end_challenge_pressed
signal finish_dish_pressed
signal reset_dish_pressed

#State
var disabled:bool = false
var result_active:bool = false
var result_panel_shown:bool = false
#plates
var plate_anim_active = false
var active_plates:int = 0

func _ready() -> void:
	event_manager.large_view_toggled.connect(toggle_large_view)
	finish_dish_button.left_clicked.connect(_on_finish_dish_button_pressed)
	reset_button.left_clicked.connect(_on_reset_button_pressed)
	result_toggle_panel_button.left_clicked.connect(_on_toggle_result_panel_pressed)
	result_end_button.left_clicked.connect(_on_end_button_pressed)
	drop_area.mouse_exited.connect(_on_drop_area_mouse_exited)

#region Animations
func animate_plates(nutrition):
	plate_anim_active = true
	var plate_diff = nutrition - active_plates
	if plate_diff > 0:
		plates[1+active_plates].visible = true
		await get_tree().create_timer(1.0/plate_anim_speed).timeout
		active_plates += 1
	else:
		plates[active_plates].visible = false
		await get_tree().create_timer(1.0/plate_anim_speed).timeout
		active_plates -= 1
	if active_plates <= 0:
		plates_shadow.visible = true
	else:
		plates_shadow.visible = false
	plate_anim_active = false

#endregion
#region Result Screen
func add_combination_result_text(combination):
	var new_text_box = result_text_combination_box.duplicate()
	result_text_vbox.add_child(new_text_box)
	var new_text = combination.name + " - " + combination.description
	new_text_box.text = new_text

func toggle_result_screen(value):
	result_screen.visible = value
	result_active = value
	toggle_mouse_filter(drop_area, not value)
	toggle_mouse_filter(reset_button, not value)
	toggle_mouse_filter(finish_dish_button, not value)

func toggle_result_panel(value):
	result_panel.visible = value
	result_panel_shown = value

#endregion
#region Button

func toggle_disable_buttons(value):
	for i in [reset_button, finish_dish_button, result_toggle_panel_button, result_end_button, drop_area]:
		i.toggle_disable(value)

func _on_reset_button_pressed() -> void:
	reset_dish_pressed.emit()


func _on_finish_dish_button_pressed() -> void:
	finish_dish_pressed.emit()

func _on_inv_toggle_pressed() -> void:
	inventory_display.visible = !inventory_display.visible

func _on_end_button_pressed() -> void:
	end_challenge_pressed.emit()

func _on_toggle_result_panel_pressed() -> void:
	if result_panel_shown:
		toggle_result_panel(false)
	else:
		toggle_result_panel(true)

func _on_drop_area_mouse_exited() -> void:
	toggle_highlight_pan(false)

#endregion
#region Dish
func toggle_highlight_pan(value):
	pan_highlight.visible = value

func update_stats(dish):
	if result_active:
		result_stats_display.update_flavours(dish.flavours, true)
		result_stats_display.update_nutrition(dish.nutrition, true)
	else:
		dish_stats_display.update_flavours(dish.flavours, false)
		dish_stats_display.update_nutrition(dish.nutrition, false)
		if active_plates != dish.nutrition and !plate_anim_active and dish.nutrition < plates.size():
			animate_plates(dish.nutrition)
#endregion
#region Signals Received
func toggle_large_view(value):
	toggle_disable_buttons(value)
#endregion
#region Helper

func toggle_mouse_filter(node:Control, value:bool):
	if value:
		node.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	else:
		node.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE

#endregion
