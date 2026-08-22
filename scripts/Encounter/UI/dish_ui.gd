extends Control
@export var result_bg_move_x:int = 80
@export var result_bg_move_duration:float = 1.0

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


func update_flavours():
	
	sweet_text.text = str(dish.sweet)
	if dish.sweet == 0:
		sweet_text.visible = false
		sweet_bg.start_moving_to_destination(Vector2(sweet_bg.global_position.x + result_bg_move_x,
		sweet_bg.global_position.y),result_bg_move_duration)
	else:
		sweet_bg.move_to_last_position(result_bg_move_duration)
		sweet_text.visible = true
	
	sour_text.text = str(dish.sour)
	if dish.sour == 0:
		sour_text.visible = false
		sour_bg.start_moving_to_destination(Vector2(sour_bg.global_position.x + result_bg_move_x,
		sour_bg.global_position.y),result_bg_move_duration)
	else:
		sour_bg.move_to_last_position(result_bg_move_duration)
		sour_text.visible = true
	
	spicy_text.text = str(dish.spicy)
	if dish.spicy == 0:
		spicy_text.visible = false
		spicy_bg.start_moving_to_destination(Vector2(spicy_bg.global_position.x + result_bg_move_x,
		spicy_bg.global_position.y),result_bg_move_duration)
	else:
		spicy_bg.move_to_last_position(result_bg_move_duration)
		spicy_text.visible = true
	
	hearty_text.text = str(dish.hearty)
	if dish.hearty == 0:
		hearty_text.visible = false
		hearty_bg.start_moving_to_destination(Vector2(hearty_bg.global_position.x + result_bg_move_x,
		hearty_bg.global_position.y),result_bg_move_duration)
	else:
		hearty_bg.move_to_last_position(result_bg_move_duration)
		hearty_text.visible = true
	
	fresh_text.text = str(dish.fresh)
	if dish.fresh == 0:
		fresh_text.visible = false
		fresh_bg.start_moving_to_destination(Vector2(fresh_bg.global_position.x + result_bg_move_x,
		fresh_bg.global_position.y),result_bg_move_duration)
	else:
		fresh_bg.move_to_last_position(result_bg_move_duration)
		fresh_text.visible = true


func update_nutrition(new_value: Variant) -> void:
	nutrition_text.text = str(new_value)
	if new_value > 0:
		nutrition_shadow.visible = true
		nutrition_text.visible = true
	else:
		nutrition_shadow.visible = false
		nutrition_text.visible = false
	var temp = 0
	for i in nutrition_plates:
		i.visible = false
		temp += 1
	for i in clampi(new_value,0,nutrition_plates.size()):
		nutrition_plates[i].visible = true

func toggle_highlight_pan(value):
	pan_highlight.visible = value

func _on_drop_area_mouse_exited() -> void:
	toggle_highlight_pan(false)
