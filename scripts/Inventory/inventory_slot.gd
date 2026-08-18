extends Panel
#PARAMS
@export var large_view:bool = false
@export var preview:bool = false

#CACHED COMPS
@onready var item_visual: TextureRect = $ItemDisplay
@onready var uses_textures = $ItemDisplay/Uses.get_children()
@onready var hearty = $ItemDisplay/Flavours/Hearty
@onready var sour = $ItemDisplay/Flavours/Sour
@onready var fresh = $ItemDisplay/Flavours/Fresh
@onready var spicy = $ItemDisplay/Flavours/Spicy
@onready var sweet = $ItemDisplay/Flavours/Sweet
@onready var nutrition_text = $ItemDisplay/NutritionText
@onready var empty_slot = $EmptySlot
@onready var rarity_textures = $ItemDisplay/Rarity.get_children()
var tags
var description

#STATE
var ingredient

func _ready() -> void:
	if large_view:
		tags = $ItemDisplay/Tags
		description = $ItemDisplay/Description

func update(item):
	
	if !item:
		item_visual.visible = false
		ingredient == null
		empty_slot.visible = true
	else:
		empty_slot.visible = false
		item_visual.visible = true
		item_visual.texture = item.get_texture()
		ingredient = item
		update_flavours()

func update_flavours():
	#flavours
	if ingredient.hearty > 0:
		hearty.visible = true
		hearty.get_child(0).text = str(ingredient.hearty)
	else:
		hearty.visible = false
		
	if ingredient.sour > 0:
		sour.visible = true
		sour.get_child(0).text = str(ingredient.sour)
	else:
		sour.visible = false
		
	if ingredient.fresh > 0:
		fresh.visible = true
		fresh.get_child(0).text = str(ingredient.fresh)
	else:
		fresh.visible = false
		
	if ingredient.spicy > 0:
		spicy.visible = true
		spicy.get_child(0).text = str(ingredient.spicy)
	else:
		spicy.visible = false
		
	if ingredient.sweet > 0:
		sweet.visible = true
		sweet.get_child(0).text = str(ingredient.sweet)
	else:
		sweet.visible = false
	
	#nutrition
	nutrition_text = str(ingredient.nutrition)
	
	#uses
	for i in uses_textures:
			i.visible = false
	for i in ingredient.uses:
			uses_textures[i].visible = true
	#rarity
	for i in rarity_textures.size():
		if i == ingredient.rarity:
			rarity_textures[i].visible = true
		else:
			rarity_textures[i].visible = false
	
	#if large view
	if large_view == true:
		tags = ingredient.get_child(0).tags
		description = ingredient.get_child(0).description

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not ingredient:
		return
	if preview:
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
	if preview:
		return false
	return true
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var tmp = ingredient
	ingredient = data.ingredient
	data.ingredient = tmp
	item_visual.show()
	data.show()
	update(ingredient)
	data.update(data.ingredient)
