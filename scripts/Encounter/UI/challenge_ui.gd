extends Control
@onready var nutrition = $nutrition
@onready var nutrition_plates = nutrition.get_children()


func _on_dish_nutrition_change(new_value: Variant) -> void:
	nutrition.text = str(new_value)
	var temp = 0
	for i in nutrition_plates:
		if (temp != 0):
			i.visible = false
		temp += 1
	for i in clampi(new_value,0,nutrition_plates.size()):
		nutrition_plates[i].visible = true
