extends Panel
#PARAMS
@export var large_view:bool = false
@export var showcase = false
@export var editor_preview:bool = false
@export var pixel_multiple:int = 8
@export var drag_pos_offset:Vector2 = Vector2(96,96)
@export var clickable:bool = true

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
var tags:RichTextLabel
var uses:int
var description:RichTextLabel
var ingredient_name:RichTextLabel
@onready var large_view_button = $large_view_button


#SIGNALS
signal large_view_clicked(card_data)

#STATE
var card
var dragging = false

func _ready() -> void:
	if editor_preview:
		visible = false
	if large_view:
		showcase = true
		tags = $ItemDisplay/Tags/RichTextLabel
		description = $ItemDisplay/Description
		ingredient_name = $ItemDisplay/Name/RichTextLabel
	if showcase:
		large_view_button.visible = false
	else:
		large_view_button.pressed.connect(large_view_pressed)

func large_view_pressed():
	large_view_clicked.emit(card)

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
		card == null
		empty_slot.visible = true
		large_view_button.visible = false
	else:
		if !showcase:
			large_view_button.visible = true
		empty_slot.visible = false
		item_visual.visible = true
		icon.texture = item.stats.icon
		card = item
		if large_view:
			#update tags display
			var tags_string = ""
			for i in card.stats.tags:
				if tags_string == "":
					tags_string += String(get_tag_name(i))
				else:
					tags_string += ", " + String(get_tag_name(i))
			tags.text = tags_string
			description.text = card.stats.description
			ingredient_name.text = card.stats.name
		update_flavours()
		update_uses()

func update_uses(value = uses):
	uses = value
	for i in uses_textures:
			i.visible = false
	for i in card.stats.uses:
			uses_textures[i].visible = true

func update_flavours():
	#flavours
	if card.stats.hearty > 0:
		hearty.visible = true
		hearty.get_child(0).text = str(card.stats.hearty)
		if card.stats.hearty != card.base_stats.hearty:
			hearty.get_child(0).theme_type_variation = "altered"
		else:
			hearty.get_child(0).theme_type_variation = "hearty"
	else:
		if card.stats.hearty != card.base_stats.hearty:
			hearty.get_child(0).theme_type_variation = "altered"
		else:
			hearty.get_child(0).theme_type_variation = "hearty"
			hearty.visible = false
		
	if card.stats.sour > 0:
		sour.visible = true
		sour.get_child(0).text = str(card.stats.sour)
		if card.stats.sour != card.base_stats.sour:
			sour.get_child(0).theme_type_variation = "altered"
		else:
			sour.get_child(0).theme_type_variation = "sour"
	else:
		if card.stats.sour != card.base_stats.sour:
			sour.get_child(0).theme_type_variation = "altered"
		else:
			sour.get_child(0).theme_type_variation = "sour"
			sour.visible = false
		
	if card.stats.fresh > 0:
		fresh.visible = true
		fresh.get_child(0).text = str(card.stats.fresh)
		if card.stats.fresh != card.base_stats.fresh:
			fresh.get_child(0).theme_type_variation = "altered"
		else:
			fresh.get_child(0).theme_type_variation = "fresh"
	else:
		if card.stats.fresh != card.base_stats.fresh:
			fresh.get_child(0).theme_type_variation = "altered"
		else:
			fresh.get_child(0).theme_type_variation = "fresh"
			fresh.visible = false
		
	if card.stats.spicy > 0:
		spicy.visible = true
		spicy.get_child(0).text = str(card.stats.spicy)
		if card.stats.spicy != card.base_stats.spicy:
			spicy.get_child(0).theme_type_variation = "altered"
		else:
			spicy.get_child(0).theme_type_variation = "spicy"
	else:
		if card.stats.spicy != card.base_stats.spicy:
			spicy.get_child(0).theme_type_variation = "altered"
		else:
			spicy.get_child(0).theme_type_variation = "spicy"
			spicy.visible = false
		
	if card.stats.sweet > 0:
		sweet.visible = true
		sweet.get_child(0).text = str(card.stats.sweet)
		if card.stats.sweet != card.base_stats.sweet:
			sweet.get_child(0).theme_type_variation = "altered"
		else:
			sweet.get_child(0).theme_type_variation = "sweet"
	else:
		if card.stats.sweet != card.base_stats.sweet:
			sweet.get_child(0).theme_type_variation = "altered"
		else:
			sweet.get_child(0).theme_type_variation = "sweet"
			sweet.visible = false
	
	#nutrition
	nutrition_text.text = str(card.stats.nutrition)
	if card.stats.nutrition != card.base_stats.nutrition:
		nutrition_text.theme_type_variation = "altered"
	else:
		nutrition_text.theme_type_variation = "standard"
	
	#rarity
	for i in rarity_textures.size():
		if i == card.stats.rarity:
			rarity_textures[i].visible = true
		else:
			rarity_textures[i].visible = false

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not card:
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
	var tmp = card
	card = data.card
	item_visual.show()
	update(card)
	if !showcase:
		data.card = tmp
		data.show()
		data.update(data.card)

func _process(delta: float) -> void:
	if !dragging:
		return
	var new_pos = get_global_mouse_position() - drag_pos_offset
	global_position = (new_pos / pixel_multiple).round() * pixel_multiple


func get_tag_name(tag:GlobalEnums.Tags):
	#match tag name to int
	return "tag_fix this code"
	pass
