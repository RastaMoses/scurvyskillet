extends Control
@export var result_bg_move_x:int = 80
@export var result_bg_move_duration:float = 1.0
@export var plate_anim_speed:float = 1

@onready var dish = get_parent()
@onready var sweet_text = $Results/SweetText
@onready var sour_text = $Results/SourText
@onready var spicy_text = $Results/SpicyText
@onready var hearty_text = $Results/HeartyText
@onready var fresh_text = $Results/FreshText

@onready var sweet_bg = $Results/Sweet
@onready var spicy_bg = $Results/Spicy
@onready var hearty_bg = $Results/Hearty
@onready var fresh_bg = $Results/Fresh
@onready var sour_bg = $Results/Sour


@onready var nutrition_text = $Nutrition/text
@onready var nutrition_plates = $Nutrition/plates.get_children()
@onready var nutrition_shadow = $Nutrition/shadow
@onready var pan_highlight = $Pan/highlight

var sweet_bg_moved = false
var sour_bg_moved = false
var spicy_bg_moved = false
var hearty_bg_moved = false
var fresh_bg_moved = false

var plate_anim_active = false
var active_plates:int = 0
var current_nutrition:int = 0

func update_flavours():
	
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
	
	sour_text.text = str(dish.sour)
	if dish.sour == 0:
		sour_text.visible = false
		if !sour_bg_moved:
			sour_bg.start_moving_to_destination(Vector2(sour_bg.global_position.x + result_bg_move_x,
			sour_bg.global_position.y),result_bg_move_duration)
			sour_bg_moved = true
	else:
		sour_bg.start_moving_to_destination(sour_bg.start_location, result_bg_move_duration)
		sour_text.visible = true
		sour_bg_moved = false
	
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

func toggle_highlight_pan(value):
	pan_highlight.visible = value

func _on_drop_area_mouse_exited() -> void:
	toggle_highlight_pan(false)

func _process(delta: float) -> void:
	if active_plates != current_nutrition and !plate_anim_active:
		animate_plates()

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
