extends Control
@export_subgroup("Params")
@export var plate_anim_speed:float = 1
@export_group("Nodes")
@export var challenge:Challenge
@export_subgroup("Result Screen")
@export var result_stats_display:StatsDisplayer
@export var result_toggle_panel_button:ButtonUI
@export var result_end_button:ButtonUI
@export var result_screen:Control
@export var result_panel:Control
@export var combination_vbox:VBoxContainer
@export var combination_display_scroll:ScrollContainer
@export var combination_display_scene:PackedScene
@export var combination_inventory:Inventory
@export var combination_inventory_scroll:InventoryScrollbar
@export_subgroup("Dish")
@export var dish_stats_display:StatsDisplayer
@export var pan_highlight:Control
@export var drop_area:DropArea
@export var reset_button:ButtonUI
@export var finish_dish_button:ButtonUI
@export var plate_parent:Control
@export var plates_shadow:Control
@export_subgroup("Description")
@export var des_vbox:VBoxContainer
@export var inventory_display:InventoryUI

#Onready
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
@onready var combination_manager:CombinationManager = get_tree().get_first_node_in_group("combination_manager")

#Signals
signal end_challenge_pressed
signal finish_dish_pressed
signal reset_dish_pressed

#State
var disabled:bool = false
	#Result Screen
var result_active:bool = false
var result_panel_shown:bool = false
#plates
var plates:Array
var plate_anim_active = false
var active_plates:int = 0

func _ready() -> void:
	plates = plate_parent.get_children()
	event_manager.large_view_toggled.connect(toggle_large_view)
	finish_dish_button.left_clicked.connect(_on_finish_dish_button_pressed)
	reset_button.left_clicked.connect(_on_reset_button_pressed)
	result_toggle_panel_button.left_clicked.connect(_on_toggle_result_panel_pressed)
	result_end_button.left_clicked.connect(_on_end_button_pressed)
	drop_area.mouse_exited.connect(_on_drop_area_mouse_exited)
	combination_display_scroll.get_v_scroll_bar().changed.connect(scroll_bar_auto_bottom)
	
	#Set Start UI
	combination_inventory.init_inventory()
	start_result_screen(false)
	inventory_display.visible= false

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
func add_combination_result(combination, comb_cards_arrays):
	var new_combination_display = combination_display_scene.instantiate()
	combination_vbox.add_child(new_combination_display)
	new_combination_display.init_ui(combination, comb_cards_arrays)
	new_combination_display.hover_start.connect(combination_mouse_hover_start)
	new_combination_display.hover_stop.connect(combination_mouse_hover_stop)
	#Update Flavour and Mult Display
	result_stats_display.update_flavours(combination_manager.get_current_flavour_multiplier_sum(true))
	result_stats_display.update_nutrition(combination_manager.get_current_nutrition_multiplier_sum(true))
	dish_stats_display.update_flavours(combination_manager.upgraded_dish.flavours, true, true)
	dish_stats_display.update_nutrition(combination_manager.upgraded_dish.nutrition, true, true)

func set_combination_inventory(combination, card_arrays):
	combination_inventory.destroy_all_ingredients()
	for cards in card_arrays:
		for card in cards:
			combination_inventory.add_card(card)

func start_result_screen(value):
	result_screen.visible = value
	result_active = value
	toggle_result_panel(value)
	toggle_result_buttons(false)
	toggle_mouse_filter(drop_area, not value)
	toggle_mouse_filter(reset_button, not value)
	toggle_mouse_filter(finish_dish_button, not value)

func toggle_result_panel(value):
	result_panel.visible = value
	result_panel_shown = value
	if value == true:
		update_stats(combination_manager.upgraded_dish, true, true)
	else:
		update_stats(combination_manager.dish, false, false)

func toggle_result_buttons(value):
	for i in [result_toggle_panel_button, result_end_button]:
		i.toggle_disabled(!value)
		i.visible = value

func scroll_bar_auto_bottom():
	combination_display_scroll.scroll_vertical = combination_display_scroll.get_v_scroll_bar().max_value
#endregion
#region Button

func toggle_disabled_buttons(value):
	for i in [reset_button, finish_dish_button, result_toggle_panel_button, result_end_button, drop_area]:
		i.toggle_disabled(value)

func _on_reset_button_pressed() -> void:
	reset_dish_pressed.emit()

func _on_finish_dish_button_pressed() -> void:
	finish_dish_pressed.emit()

func _on_inv_toggle_pressed() -> void:
	inventory_display.visible = !inventory_display.visible

func _on_end_button_pressed() -> void:
	end_challenge_pressed.emit()

func _on_toggle_result_panel_pressed() -> void:
	toggle_result_panel(!result_panel_shown)

func combination_mouse_hover_start(combination, card_arrays):
	set_combination_inventory(combination, card_arrays)
	combination_inventory.ui.open()
	combination_inventory_scroll.toggle_autoscroll(true)
	
func combination_mouse_hover_stop():
	combination_inventory.ui.close()
	combination_inventory_scroll.toggle_autoscroll(false)
	
func _on_drop_area_mouse_exited() -> void:
	toggle_highlight_pan(false)

#endregion
#region Dish
func toggle_highlight_pan(value):
	pan_highlight.visible = value

func update_stats(dish, force_show = false, altered_font_color = false):
	if dish != null:
		dish_stats_display.update_flavours(dish.flavours, force_show, altered_font_color)
		dish_stats_display.update_nutrition(dish.nutrition, force_show, altered_font_color)
		if active_plates != dish.nutrition and !plate_anim_active and dish.nutrition < plates.size():
			animate_plates(dish.nutrition)
#endregion
#region Signals Received
func toggle_large_view(value):
	toggle_disabled_buttons(value)

func combinations_done():
	toggle_result_buttons(true)
#endregion
#region Helper

func toggle_mouse_filter(node:Control, value:bool):
	if value:
		node.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	else:
		node.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE

#endregion
