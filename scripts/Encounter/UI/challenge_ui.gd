extends Control
@export_subgroup("Flavour Display")
@export var result_bg_move_x:int = 80
@export var result_bg_move_duration:float = 1.0
@export var plate_anim_speed:float = 1

#Onready

@onready var sweet_text = $Dish/Results/SweetText
@onready var spicy_text = $Dish/Results/SpicyText
@onready var hearty_text = $Dish/Results/HeartyText
@onready var fresh_text = $Dish/Results/FreshText

@onready var sweet_bg = $Dish/Results/Sweet
@onready var spicy_bg = $Dish/Results/Spicy
@onready var hearty_bg = $Dish/Results/Hearty
@onready var fresh_bg = $Dish/Results/Fresh


@onready var nutrition_text = $Dish/Nutrition/text
@onready var nutrition_plates = $Dish/Nutrition/plates.get_children()
@onready var nutrition_shadow = $Dish/Nutrition/shadow
@onready var pan_highlight = $Dish/Pan/highlight
@onready var drop_area = $Dish/DropArea

@onready var reset = $Reset
@onready var reset_button = $Reset/reset_button
@onready var reset_button_arrow = $Reset/reset_bag_arrow
@onready var finish_dish_button = $Finish/finish_dish_button
@onready var ladle_hover = $Finish/ladle_hover
@onready var ladle_highlight = $Finish/highlight
@onready var des_vbox = $description/ScrollContainer/VBoxContainer
@onready var inventory_display = $InventoryUI
#Result Screen
@onready var result_end_button = $ResultScreen/ResultPanel/EndButton
@onready var result_toggle_panel_button = $ResultScreen/ToggleResultPanel
@onready var result_screen = $ResultScreen
@onready var result_panel = $ResultScreen/ResultPanel
@onready var result_text_vbox = $ResultScreen/ResultPanel/ScrollContainer/VBoxContainer
@onready var result_text_combination_box = $ResultScreen/ResultPanel/ScrollContainer/VBoxContainer/combination_text
var disabled:bool = false
var result_active:bool = false
var result_panel_shown:bool = false

#Signals
signal end_challenge_pressed
signal finish_dish_pressed
signal reset_dish_pressed

#State
var sweet_bg_moved = false
var spicy_bg_moved = false
var hearty_bg_moved = false
var fresh_bg_moved = false

var plate_anim_active = false
var active_plates:int = 0
var current_nutrition:int = 0

func _ready() -> void:
	finish_dish_button.pressed.connect(_on_finish_dish_button_pressed)
	reset_button.pressed.connect(_on_reset_button_pressed)
	result_toggle_panel_button.pressed.connect(_on_toggle_result_panel_pressed)
	result_end_button.pressed.connect(_on_end_button_pressed)
	drop_area.mouse_exited.connect(_on_drop_area_mouse_exited)

func _process(delta: float) -> void:
	if active_plates != current_nutrition and !plate_anim_active and current_nutrition < nutrition_plates.size():
		animate_plates()

func toggle_result_screen(value):
	result_screen.visible = value
	result_active = value
	toggle_mouse_filter(drop_area, not value)
	toggle_mouse_filter(reset_button, not value)
	toggle_mouse_filter(finish_dish_button, not value)

func toggle_result_panel(value):
	result_panel.visible = value
	result_panel_shown = value

func toggle_disable_buttons(value):
	disabled = value
	finish_dish_button.disabled = value
	reset_button.disabled = value
	result_toggle_panel_button.disabled = value
	result_end_button.disabled = value
	for i in [reset_button, finish_dish_button, result_toggle_panel_button, result_end_button, drop_area]:
		toggle_mouse_filter(i, !value)
	
	reset_button_arrow.visible = false
	ladle_hover.visible = false
	ladle_highlight.visible = false

func toggle_mouse_filter(node:Control, value:bool):
	print("toggle mouse filter challenge ui")
	if value:
		node.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	else:
		node.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE

func add_combination_result_text(combination):
	var new_text_box = result_text_combination_box.duplicate()
	result_text_vbox.add_child(new_text_box)
	var new_text = combination.name + " - " + combination.description
	new_text_box.text = new_text

func update_flavours(dish):
	sweet_text.text = str(dish.sweet)
	if dish.sweet == 0:
		sweet_text.visible = false
		if !sweet_bg_moved:
			sweet_bg.start_moving_to_destination(Vector2(sweet_bg.global_position.x + result_bg_move_x,
			sweet_bg.global_position.y),result_bg_move_duration)
			sweet_bg_moved = true
	else:
		sweet_bg.start_moving_to_destination(sweet_bg.start_location, result_bg_move_duration)
		sweet_text.visible = true
		sweet_bg_moved = false
	
	spicy_text.text = str(dish.spicy)
	if dish.spicy == 0:
		spicy_text.visible = false
		if !spicy_bg_moved:
			spicy_bg.start_moving_to_destination(Vector2(spicy_bg.global_position.x + result_bg_move_x,
			spicy_bg.global_position.y),result_bg_move_duration)
			spicy_bg_moved = true
	else:
		spicy_bg.start_moving_to_destination(spicy_bg.start_location, result_bg_move_duration)
		spicy_text.visible = true
		spicy_bg_moved = false
	
	hearty_text.text = str(dish.hearty)
	if dish.hearty == 0:
		hearty_text.visible = false
		if !hearty_bg_moved:
			hearty_bg.start_moving_to_destination(Vector2(hearty_bg.global_position.x + result_bg_move_x,
			hearty_bg.global_position.y),result_bg_move_duration)
			hearty_bg_moved = true
	else:
		hearty_bg.start_moving_to_destination(hearty_bg.start_location, result_bg_move_duration)
		hearty_text.visible = true
		hearty_bg_moved = false
	
	fresh_text.text = str(dish.fresh)
	if dish.fresh == 0:
		fresh_text.visible = false
		if !fresh_bg_moved:
			fresh_bg.start_moving_to_destination(Vector2(fresh_bg.global_position.x + result_bg_move_x,
			fresh_bg.global_position.y),result_bg_move_duration)
			fresh_bg_moved = true
	else:
		fresh_bg.start_moving_to_destination(fresh_bg.start_location, result_bg_move_duration)
		fresh_text.visible = true
		fresh_bg_moved = false

func update_nutrition(new_value: Variant) -> void:
	nutrition_text.text = str(new_value)
	current_nutrition = new_value
	if new_value > 0:
		nutrition_shadow.visible = true
		nutrition_text.visible = true
	else:
		nutrition_shadow.visible = false
		nutrition_text.visible = false
func animate_plates():
	plate_anim_active = true
	var plate_diff = current_nutrition - active_plates
	if plate_diff > 0:
		nutrition_plates[1+active_plates].visible = true
		await get_tree().create_timer(1.0/plate_anim_speed).timeout
		active_plates += 1
	else:
		nutrition_plates[active_plates].visible = false
		await get_tree().create_timer(1.0/plate_anim_speed).timeout
		active_plates -= 1
	plate_anim_active = false

#region Button Inputs
func _on_reset_button_pressed() -> void:
	reset_dish_pressed.emit()

func _on_reset_button_mouse_entered() -> void:
	if disabled:
		return
	reset_button_arrow.visible = true

func _on_reset_button_mouse_exited() -> void:
	if disabled:
		return
	reset_button_arrow.visible = false

func _on_finish_dish_button_pressed() -> void:
	finish_dish_pressed.emit()

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

#endregion
