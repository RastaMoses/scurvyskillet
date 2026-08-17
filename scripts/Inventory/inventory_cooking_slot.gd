extends Panel

@onready var item_visual: TextureRect = $ItemDisplay
var ingredient

func update(item):
	if !item:
		item_visual.visible = false
		ingredient == null
	else:
		item_visual.visible = true
		item_visual.texture = item.get_texture()
		ingredient = item

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not ingredient:
		return

	var preview = duplicate()
	var c = Control.new()
	c.add_child(preview)
	preview.position -= Vector2(25,25)
	preview.self_modulate = Color.TRANSPARENT
	c.modulate = Color(c.modulate, 0.7)
	set_drag_preview(c)
	item_visual.hide()
	return self

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var tmp = ingredient
	ingredient = data.ingredient
	data.ingredient = tmp
	item_visual.show()
	data.show()
	update(ingredient)
	data.update(data.ingredient)
