extends Panel
#PARAMS
@export var large_view:bool = false
@export var editor_preview:bool = false
@export var pixel_multiple:int = 8
@export var drag_pos_offset:Vector2 = Vector2(96,96)

#CACHED COMPS
@onready var item_visual: TextureRect = $ItemDisplay
@onready var texture = $ItemDisplay.texture
@onready var uses_textures = $ItemDisplay/Uses.get_children()
@onready var hearty = $ItemDisplay/Flavours/Hearty
@onready var sour = $ItemDisplay/Flavours/Sour
@onready var fresh = $ItemDisplay/Flavours/Fresh
@onready var spicy = $ItemDisplay/Flavours/Spicy
@onready var sweet = $ItemDisplay/Flavours/Sweet
@onready var nutrition_text = $ItemDisplay/Nutrition/NutritionText
@onready var empty_slot = $EmptySlot
@onready var rarity_textures = $ItemDisplay/Rarity.get_children()
@onready var icon = $ItemDisplay/item_icon
var tags
var description
var ingredient_name
@onready var large_view_button = $large_view_button

#SIGNALS
signal large_view_clicked(ingredient_data)

#STATE
var ingredient
var showcase = false
var dragging = false

func _ready() -> void:
	if editor_preview:
		visible = false
	if large_view:
		showcase = true
		tags = $ItemDisplay/Tags/RichTextLabel
		description = $ItemDisplay/Description
		ingredient_name = $ItemDisplay/Name/RichTextLabel
	large_view_button.pressed.connect(large_view_pressed)

func large_view_pressed():
	large_view_clicked.emit(ingredient)

func toggle_only_icon(value):
	if value:
		for i in $ItemDisplay.get_children():
			i.visible = false
		$ItemDisplay/item_icon.visible = true
	else:
		for i in item_visual.get_children():
			i.visible = true

func update(item):
	if !item:
		item_visual.visible = false
		ingredient == null
		empty_slot.visible = true
		large_view_button.visible = false
	else:
		large_view_button.visible = true
		empty_slot.visible = false
		item_visual.visible = true
		icon.texture = item.get_icon_texture()
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
	nutrition_text.text = str(ingredient.nutrition)
	
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
		tags = ingredient.get_preview().tags
		description = ingredient.get_preview().description
		ingredient_name = ingredient.get_preview().ingredient_name

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not ingredient:
		return
	if showcase:
		return
	var preview = duplicate()
	preview.toggle_only_icon(true)
	var c = Control.new()
	c.add_child(preview)
	preview.dragging = true
	preview.position -= drag_pos_offset
	preview.z_index = 100
	preview.self_modulate = Color.TRANSPARENT
	c.modulate = Color(c.modulate, 0.7)
	set_drag_preview(c)
	item_visual.hide()
	return self

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	if showcase:
		return false
	return true
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var tmp = ingredient
	ingredient = data.ingredient
	item_visual.show()
	update(ingredient)
	if !showcase:
		data.ingredient = tmp
		data.show()
		data.update(data.ingredient)

func _process(delta: float) -> void:
	if !dragging:
		return
	var new_pos = get_global_mouse_position() - drag_pos_offset
	global_position = (new_pos / pixel_multiple).round() * pixel_multiple
