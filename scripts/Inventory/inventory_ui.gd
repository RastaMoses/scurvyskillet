class_name InventoryUI
extends Control

#PARAMS
@export var inventory_slot_scene:PackedScene
@export var min_slots: int = 10

@export_group("Inventory Positions")
@export var max_rows:int = 3
@export var horizontal = true
@export var max_columns:int = 2

@export_group("Nodes")
@export var inventory:Inventory
@export var slots:Array[CardSlot]
@export var grid_container:GridContainer
@export var scroll_container:ScrollContainer
@export var bg:TextureRect

#CACHED COMPS
var event_manager
var large_view


#STATE
var data_bk
var large_view_active = false
var negative_slots:Array[CardSlot]
var is_open = false

func init_ui():
	large_view = get_tree().get_first_node_in_group("card_large_view")
	event_manager = get_tree().get_first_node_in_group("event_manager")
	for i in slots:
		i.init_slot(self)
		i.large_view_clicked.connect(large_view.button_pressed)
		i.dragged.connect(card_dragged)
		i.stop_drag.connect(card_drag_ended)

func adjust_grid_columns():
	if (horizontal):
		var grid_container_active_children:int = 0
		for i in grid_container.get_children():
			if i.visible:
				grid_container_active_children += 1
		var new_columns = ceili(float(grid_container_active_children)/float(max_rows))
		grid_container.columns = new_columns
	else:
		grid_container.columns = max_columns

#Drag and drop not outside window
func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_DRAG_BEGIN:
		data_bk = get_viewport().gui_get_drag_data()
	if what == Node.NOTIFICATION_DRAG_END:
		if not is_drag_successful():
			if data_bk:
				data_bk.item_visual.show()
				data_bk = null

func open():
	scroll_container.visible = true
	is_open = true
	large_view.reset_large_view()
	update_slots()
	if bg:
		bg.visible = true

func close():
	large_view.reset_large_view()
	scroll_container.visible = false
	is_open = false
	if bg:
		bg.visible = false
#region Large View

#endregion

#region Ability UI
func card_dragged(card):
	inventory.set_card_drag(card)
func card_drag_ended(_card):
	inventory.stop_card_drag()
#endregion

#region Sorting
func get_slots_cards_list() -> Array[Card]:
	var card_order:Array[Card] = []
	for slot in slots:
		if slot.card != null:
			card_order.append(slot.card)
	return card_order
func update_slots_order():
	var slot_order: Array[Card] = get_slots_cards_list()
	# Reorder current_cards to match the visual slot order
	# Only if the slot order differs from current_cards
	if slot_order.size() > 0 and slot_order.size() == inventory.current_cards.size():
		var needs_reorder = false
		for i in range(slot_order.size()):
			if slot_order[i] != inventory.current_cards[i]:
				needs_reorder = true
				break
		if needs_reorder:
			inventory.current_cards = slot_order

func sort_inventory_alphabetically():
	inventory.current_cards.sort_custom(sort_by_name)
	update_slots()
func sort_inventory_by_rarity():
	inventory.current_cards.sort_custom(sort_by_rarity)
	update_slots()
		
func sort_by_rarity(a,b):
	if not a or not b:
		return false
	if not a.committed_stats or not b.committed_stats:
		return false
	if a.committed_stats.rarity < b.committed_stats.rarity:
		return false
	if a.committed_stats.rarity > b.committed_stats.rarity:
		return true
	return a.committed_stats.uses > b.committed_stats.uses
func sort_by_name(a, b): 
	if not a or not b:
		return false
	if not a.committed_stats or not b.committed_stats:
		return false
	var cmp:int = a.committed_stats.name.naturalnocasecmp_to(b.committed_stats.name)
	if cmp != 0:
		return cmp < 0
	return a.committed_stats.uses > b.committed_stats.uses

func _on_rarity_button_left_clicked() -> void:
	sort_inventory_by_rarity()


func _on_alphabet_button_left_clicked() -> void:
	sort_inventory_alphabetically()

#endregion

#region Slots

func add_slot():
	var temp = inventory_slot_scene.instantiate()
	grid_container.add_child(temp)
	slots.append(temp)
	temp.init_slot(self)
	temp.large_view_clicked.connect(large_view.button_pressed)
	temp.dragged.connect(card_dragged)
	temp.stop_drag.connect(card_drag_ended)

func remove_slots(amount):
	var i = 0
	while i < amount:
		i += 1
		slots.back().queue_free()
		slots.remove_at(-1)

func update_slots():
	#check slot amount
	var slots_to_remove = 0
	while inventory.current_cards.size() > slots.size():
		add_slot()
	for i in range(slots.size()):
		#update slots with items
		if (inventory.current_cards.size() > i):
			slots[i].update(inventory.current_cards[i])
		else:
			if i > min_slots - 1:
				slots_to_remove += 1
			else:
				slots[i].update(null)
		slots[i].showcase = !inventory.can_drag_cards
	remove_slots(slots_to_remove)
	
	#if bottom adjust column amount
	adjust_grid_columns()
		#Scrollbar
	scroll_container._call_deferred_update_hints()

func set_slot_negative(card, value):
	var slot = get_card_slot(card)
	slot.toggle_icon_bg_negative(value)
	if value == true:
		negative_slots.append(slot)
	else:
		negative_slots.erase(slot)

func set_all_slots_negative(value):
	for slot in slots:
		slot.toggle_icon_bg_negative(value)
		if value == true:
			negative_slots.append(slot)
		else:
			negative_slots.erase(slot)
func get_card_slot(card):
	for slot in slots:
		if slot.card == card:
			return slot
	printerr("Slot for Card: " + str(card.name) + " not found.")
	return null
#endregion
