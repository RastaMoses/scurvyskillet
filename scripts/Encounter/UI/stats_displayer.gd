class_name StatsDisplayer
extends Control
@export_group("Params")
@export var percent:bool = false
@export var always_show:bool = false
@export var result_bg_move_x:int = 80
@export var result_bg_move_y:int = 0
@export var result_bg_move_duration:float = 1.0
@export_group("Nodes")
@export var flavours_texts:Dictionary[GlobalEnums.Flavour, RichTextLabel]
@export var flavours_bgs:Dictionary[GlobalEnums.Flavour, TextureRect]

@export var nutrition_text:RichTextLabel
@export var nutrition_bg:TextureRect

var flavour_bg_moved:Dictionary[GlobalEnums.Flavour, bool] = {GlobalEnums.Flavour.SWEET: false, GlobalEnums.Flavour.SPICY: false,GlobalEnums.Flavour.HEARTY: false,GlobalEnums.Flavour.FRESH: false}

func update_flavours(flavours:Dictionary[GlobalEnums.Flavour, int], force_show:bool = always_show, altered_font_color:bool = false):
	for flavour in GlobalEnums.Flavour:
		if GlobalEnums.Flavour[flavour] == GlobalEnums.Flavour.NONE:
			continue
	
		flavours_texts[GlobalEnums.Flavour[flavour]].text = str(flavours[GlobalEnums.Flavour[flavour]])
		if percent:
			flavours_texts[GlobalEnums.Flavour[flavour]].text += "%"
		if altered_font_color:
			flavours_texts[GlobalEnums.Flavour[flavour]].theme_type_variation = "altered"
		else:
			flavours_texts[GlobalEnums.Flavour[flavour]].theme_type_variation = "standard"
		if flavours[GlobalEnums.Flavour[flavour]] == 0 and not force_show:
			flavours_texts[GlobalEnums.Flavour[flavour]].visible = false
			if !flavour_bg_moved[GlobalEnums.Flavour[flavour]]:
				if flavours_bgs[GlobalEnums.Flavour[flavour]] != null:
					flavours_bgs[GlobalEnums.Flavour[flavour]].start_moving_to_destination(Vector2(flavours_bgs[GlobalEnums.Flavour[flavour]].position.x + result_bg_move_x,
					flavours_bgs[GlobalEnums.Flavour[flavour]].position.y + result_bg_move_y),result_bg_move_duration)
				flavour_bg_moved[GlobalEnums.Flavour[flavour]] = true
		else:
			if flavours_bgs[GlobalEnums.Flavour[flavour]] != null:
				flavours_bgs[GlobalEnums.Flavour[flavour]].start_moving_to_destination(flavours_bgs[GlobalEnums.Flavour[flavour]].start_location, result_bg_move_duration)
			flavours_texts[GlobalEnums.Flavour[flavour]].visible = true
			flavour_bg_moved[GlobalEnums.Flavour[flavour]] = false

func update_nutrition(new_value: Variant, force_show:bool = always_show, altered_font_color:bool = false) -> void:
	nutrition_text.text = str(new_value)
	if percent:
		nutrition_text.text += "%"
	if altered_font_color:
		nutrition_text.theme_type_variation = "altered"
	else:
		nutrition_text.theme_type_variation = "standard"
	if new_value <= 0 and not force_show:
		if nutrition_bg != null:
			nutrition_bg.visible = false
		nutrition_text.visible = false
	else:
		if nutrition_bg != null:
			nutrition_bg.visible = true
		nutrition_text.visible = true
