class_name StatsDisplayer
extends Control
@export_group("Params")
@export var result_bg_move_x:int = 80
@export var result_bg_move_y:int = 0
@export var result_bg_move_duration:float = 1.0
@export_group("Nodes")
@export var sweet_text:RichTextLabel
@export var spicy_text:RichTextLabel
@export var hearty_text:RichTextLabel
@export var fresh_text:RichTextLabel

@export var sweet_bg:TextureRect
@export var spicy_bg:TextureRect
@export var hearty_bg:TextureRect
@export var fresh_bg:TextureRect

@export var nutrition_text:RichTextLabel
@export var nutrition_bg:TextureRect

var sweet_bg_moved = false
var spicy_bg_moved = false
var hearty_bg_moved = false
var fresh_bg_moved = false

func update_flavours(flavours:Dictionary[GlobalEnums.Flavour, int], force_show:bool = false):
	sweet_text.text = str(flavours[GlobalEnums.Flavour.SWEET])
	if flavours[GlobalEnums.Flavour.SWEET] == 0 and not force_show:
		sweet_text.visible = false
		if !sweet_bg_moved:
			if sweet_bg != null:
				sweet_bg.start_moving_to_destination(Vector2(sweet_bg.global_position.x + result_bg_move_x,
				sweet_bg.global_position.y + result_bg_move_y),result_bg_move_duration)
			sweet_bg_moved = true
	else:
		if sweet_bg != null:
			sweet_bg.start_moving_to_destination(sweet_bg.start_location, result_bg_move_duration)
		sweet_text.visible = true
		sweet_bg_moved = false
	
	spicy_text.text = str(flavours[GlobalEnums.Flavour.SPICY])
	if flavours[GlobalEnums.Flavour.SPICY] == 0 and not force_show:
		spicy_text.visible = false
		if !spicy_bg_moved:
			if spicy_bg != null:
				spicy_bg.start_moving_to_destination(Vector2(spicy_bg.global_position.x + result_bg_move_x,
				spicy_bg.global_position.y + result_bg_move_y),result_bg_move_duration)
			spicy_bg_moved = true
	else:
		if spicy_bg != null:
			spicy_bg.start_moving_to_destination(spicy_bg.start_location, result_bg_move_duration)
		spicy_text.visible = true
		spicy_bg_moved = false
	
	hearty_text.text = str(flavours[GlobalEnums.Flavour.HEARTY])
	if flavours[GlobalEnums.Flavour.HEARTY] == 0 and not force_show:
		hearty_text.visible = false
		if !hearty_bg_moved:
			if hearty_bg != null:
				hearty_bg.start_moving_to_destination(Vector2(hearty_bg.global_position.x + result_bg_move_x,
				hearty_bg.global_position.y + result_bg_move_y),result_bg_move_duration)
			hearty_bg_moved = true
	else:
		if hearty_bg != null:
			hearty_bg.start_moving_to_destination(hearty_bg.start_location, result_bg_move_duration)
		hearty_text.visible = true
		hearty_bg_moved = false
	
	fresh_text.text = str(flavours[GlobalEnums.Flavour.FRESH])
	if flavours[GlobalEnums.Flavour.FRESH] == 0 and not force_show:
		fresh_text.visible = false
		if !fresh_bg_moved:
			if fresh_bg != null:
				fresh_bg.start_moving_to_destination(Vector2(fresh_bg.global_position.x + result_bg_move_x,
				fresh_bg.global_position.y + result_bg_move_y),result_bg_move_duration)
			fresh_bg_moved = true
	else:
		if hearty_bg != null:
			fresh_bg.start_moving_to_destination(fresh_bg.start_location, result_bg_move_duration)
		fresh_text.visible = true
		fresh_bg_moved = false

func update_nutrition(new_value: Variant, force_show:bool = false) -> void:
	nutrition_text.text = str(new_value)
	if new_value <= 0 and not force_show:
		if nutrition_bg != null:
			nutrition_bg.visible = false
		nutrition_text.visible = false
	else:
		if nutrition_bg != null:
			nutrition_bg.visible = true
		nutrition_text.visible = true
