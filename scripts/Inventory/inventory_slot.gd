class_name CardSlot
extends Panel
#PARAMS
@export var large_view:bool = false
@export var large_view_clickable = true
@export var showcase = false
@export var editor_preview:bool = false
@export var pixel_multiple:int = 8
@export var drag_pos_offset:Vector2 = Vector2(96,96)
@export var clickable:bool = true
@export var buy_item = false
@export var icon_bg_negative:TextureRect
@export var icon_bg_combination:TextureRect

#CACHED COMPS
var item_visual
var texture
var uses_textures
var flavours_display:Dictionary[GlobalEnums.Flavour, TextureRect]
var hearty
var fresh
var spicy
var sweet
var nutrition_text
var empty_slot
var rarity_textures
var icon
var tags:RichTextLabel
var uses:int
var description:RichTextLabel
var ingredient_name:RichTextLabel
var large_view_button


#SIGNALS
signal large_view_clicked(card_data, right_mouse)
signal dragged(card_data)
signal stop_drag(card_data)
signal button_mouse_entered(slot)
signal button_mouse_exited(slot)
signal slot_clicked(event)

#STATE
var card
var dragging = false
var dragging_preview = false
var ui:InventoryUI
func init_slot(ui_node = null) -> void:
	ui = ui_node
	item_visual = $ItemDisplay
	texture = $ItemDisplay.texture
	uses_textures = $ItemDisplay/Uses.get_children()
	flavours_display[GlobalEnums.Flavour.HEARTY] = $ItemDisplay/Flavours/Hearty
	flavours_display[GlobalEnums.Flavour.FRESH] = $ItemDisplay/Flavours/Fresh
	flavours_display[GlobalEnums.Flavour.SPICY] = $ItemDisplay/Flavours/Spicy
	flavours_display[GlobalEnums.Flavour.SWEET] = $ItemDisplay/Flavours/Sweet
	nutrition_text = $ItemDisplay/Nutrition/NutritionText
	empty_slot = $EmptySlot
	rarity_textures = $ItemDisplay/Rarity.get_children()
	icon = $ItemDisplay/item_icon
	large_view_button = $large_view_button
	if editor_preview:
		visible = false
	if large_view:
		showcase = true
		tags = $ItemDisplay/Tags/RichTextLabel
		description = $ItemDisplay/Description
		ingredient_name = $ItemDisplay/Name/RichTextLabel
	if !clickable:
		large_view_button.visible = false


func _process(_delta: float) -> void:
	if !dragging_preview:
		return
	var new_pos = get_global_mouse_position() - drag_pos_offset
	global_position = (new_pos / pixel_multiple).round() * pixel_multiple

func toggle_only_icon(value):
	if value:
		for i in $ItemDisplay.get_children():
			i.visible = false
		$ItemDisplay/item_icon.visible = true
	else:
		for i in item_visual.get_children():
			i.visible = true
func toggle_icon_bg_negative(value):
	icon_bg_negative.visible = value
func toggle_icon_bg_combination(value):
	icon_bg_combination.visible = value
func toggle_visuals(value):
	if !value:
		for i in item_visual.get_children():
			i.visible = false
	else:
		for i in item_visual.get_children():
			i.visible = true
func update(item):
	#Reset Altered Visuals
	if !item:
		item_visual.visible = false
		card = null
		empty_slot.visible = true
		large_view_button.visible = false
	elif dragging:
		card = item
	else:
		if clickable:
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
					tags_string += get_tag_name(i)
				else:
					tags_string += ", " + get_tag_name(i)
			tags.text = tags_string
			tags.fit_font_to_content()
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
	var card_flavours:Dictionary[GlobalEnums.Flavour, int] = card.get_flavours()
	var card_base_flavours:Dictionary[GlobalEnums.Flavour, int] = card.get_base_flavours()
	for flavour in GlobalEnums.Flavour:
		if GlobalEnums.Flavour[flavour] == GlobalEnums.Flavour.NONE:
			continue
		if card_flavours[GlobalEnums.Flavour[flavour]] > 0:
			flavours_display[GlobalEnums.Flavour[flavour]].visible = true
			flavours_display[GlobalEnums.Flavour[flavour]].get_child(0).text = str(card_flavours[GlobalEnums.Flavour[flavour]])
			if card_flavours[GlobalEnums.Flavour[flavour]] != card_base_flavours[GlobalEnums.Flavour[flavour]]:
				flavours_display[GlobalEnums.Flavour[flavour]].get_child(0).theme_type_variation = "altered"
			else:
				flavours_display[GlobalEnums.Flavour[flavour]].get_child(0).theme_type_variation = "standard"
		else:
			if card_flavours[GlobalEnums.Flavour[flavour]] != card_base_flavours[GlobalEnums.Flavour[flavour]]:
				flavours_display[GlobalEnums.Flavour[flavour]].get_child(0).theme_type_variation = "altered"
			else:
				flavours_display[GlobalEnums.Flavour[flavour]].get_child(0).theme_type_variation = "standard"
				flavours_display[GlobalEnums.Flavour[flavour]].visible = false
	
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

#region Dragging
func _get_drag_data(_at_position: Vector2) -> Variant:
	if not card:
		return
	if showcase:
		return
	var preview = duplicate()
	preview.init_slot()
	preview.toggle_only_icon(true)
	var c = Control.new()
	c.add_child(preview)
	preview.dragging_preview = true
	preview.position -= drag_pos_offset
	preview.z_index = 100
	preview.self_modulate = Color.TRANSPARENT
	c.modulate = Color(c.modulate, 0.7)
	set_drag_preview(c)
	item_visual.hide()
	#Started drag
	dragging = true
	dragged.emit(card)
	return self

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	if showcase:
		return false
	return true
	
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var tmp = card
	card = data.card
	item_visual.show()
	update(card)
	if !showcase:
		data.card = tmp
		data.show()
		data.update(data.card)
	
func _notification(what: int) -> void:
	if editor_preview:
		return
	if what == NOTIFICATION_DRAG_END:
		stopped_drag()
		if get_viewport().gui_is_drag_successful():
			if ui != null:
				ui.update_slots_order()

func stopped_drag():
	if dragging:
			stop_drag.emit(card)
			dragging = false
			update(card)

#endregion

#region Button

func _on_button_gui_input(event: InputEvent) -> void:
	if !clickable:
		return
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if buy_item:
					slot_clicked.emit(event)
				# left button clicked
				if large_view_clickable:
					large_view_clicked.emit(card, false)
			MOUSE_BUTTON_RIGHT:
				# right button clicked
				if large_view_clickable:
					large_view_clicked.emit(card, true)


func _on_large_view_button_mouse_entered() -> void:
	button_mouse_entered.emit(self)


func _on_large_view_button_mouse_exited() -> void:
	button_mouse_exited.emit(self)

#endregion

#region Helper
func get_tag_name(state: GlobalEnums.Tags) -> String:
	var enum_name := str(GlobalEnums.Tags.find_key(state)).to_lower()
	return enum_name.left(1).to_upper() + enum_name.substr(1)
#endregion
