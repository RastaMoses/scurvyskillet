class_name InventoryUI
extends Control

#PARAMS
@export var inventory_slot_scene:PackedScene
@export var min_slots: int = 10

@export_group("Inventory Positions")
@export_subgroup("Bottom Position")
@export var container_size_bottom:Vector2
@export var container_pos_bottom:Vector2

@export_subgroup("Side Position")
@export var container_size_side:Vector2
@export var container_pos_side:Vector2
@export var max_rows:int = 3


#CACHED COMPS

@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
@onready var slots: Array = $ScrollContainer/GridContainer.get_children()
@onready var inventory_container = $ScrollContainer
@onready var grid_container = $ScrollContainer/GridContainer

@onready var large_view


#STATE
var data_bk
var bottom_position = true
var large_view_active = false

var is_open = false
var inventory

func init_ui():
	large_view = get_tree().get_first_node_in_group("card_large_view")
	for i in slots:
		i.init_slot(self)
		i.large_view_clicked.connect(large_view.button_pressed)
		i.dragged.connect(card_dragged)
		i.stop_drag.connect(card_drag_ended)

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
			if i > min_slots:
				slots_to_remove += 1
			else:
				slots[i].update(null)
		slots[i].showcase = inventory.can_drag_cards
	remove_slots(slots_to_remove)
	#if bottom adjust column amount
	if (bottom_position):
		grid_container.columns = slots.size()
	else:
		var new_columns = ceili(float(slots.size())/float(max_rows))
		grid_container.columns = new_columns
		#Scrollbar
	inventory_container._call_deferred_update_hints()

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
	inventory_container.visible = true
	is_open = true
	large_view.reset_large_view()
	update_slots()
	
func close():
	large_view.reset_large_view()
	inventory_container.visible = false
	is_open = false

#region Large View

#endregion

#region Ability UI
func card_dragged(card):
	inventory.set_card_drag(card)
func card_drag_ended(card):
	inventory.stop_card_drag()
#endregion

#region Sorting
func get_slots_cards_list() -> Array[Node]:
	var card_order:Array[Node] = []
	for slot in slots:
		if slot.card != null:
			card_order.append(slot.card)
	return card_order
func update_slots_order():
	var slot_order: Array[Node] = get_slots_cards_list()
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

func _on_rarity_pressed() -> void:
	sort_inventory_by_rarity()


func _on_alphabetically_pressed() -> void:
	sort_inventory_alphabetically()
#endregion
