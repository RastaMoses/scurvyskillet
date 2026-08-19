extends Control
@onready var nutrition = $Nutrition
@onready var nutrition_plates = $Nutrition/plates.get_children()
@onready var nutrition_shadow = $Nutrition/shadow
@onready var reset = $Reset
@onready var reset_button_arrow = $Reset/reset_bag_arrow

func _on_dish_nutrition_change(new_value: Variant) -> void:
	nutrition.text = str(new_value)
	if new_value > 0:
		nutrition_shadow.visible = true
	else:
		nutrition_shadow.visible = false
	var temp = 0
	for i in nutrition_plates:
		i.visible = false
		temp += 1
	for i in clampi(new_value,0,nutrition_plates.size()):
		nutrition_plates[i].visible = true


func _on_reset_button_mouse_entered() -> void:
	reset_button_arrow.visible = true


func _on_reset_button_mouse_exited() -> void:
	reset_button_arrow.visible = false
