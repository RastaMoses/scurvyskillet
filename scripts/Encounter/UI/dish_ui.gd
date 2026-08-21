extends Control

@onready var dish = get_parent()
@onready var sweet_text = $Results/Sweet/RichTextLabel
@onready var sour_text = $Results/Sour/RichTextLabel
@onready var spicy_text = $Results/Spicy/RichTextLabel
@onready var hearty_text = $Results/Hearty/RichTextLabel
@onready var fresh_text = $Results/Fresh/RichTextLabel

@onready var nutrition_text = $Nutrition/text
@onready var nutrition_plates = $Nutrition/plates.get_children()
@onready var nutrition_shadow = $Nutrition/shadow
@onready var pan_highlight = $Pan/highlight

func update_flavours():
	sweet_text.text = str(dish.sweet)
	sour_text.text = str(dish.sour)
	spicy_text.text = str(dish.spicy)
	hearty_text.text = str(dish.hearty)
	fresh_text.text = str(dish.fresh)

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
