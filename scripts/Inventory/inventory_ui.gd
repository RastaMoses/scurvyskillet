extends Control

#PARAMS
@export var inventory_slot_scene:PackedScene
@export var min_slots: int = 10
@export var large_view_bg_fade_speed = 1

@export_group("Inventory Positions")
@export_subgroup("Bottom Position")
@export var container_size_bottom:Vector2
@export var container_pos_bottom:Vector2

@export_subgroup("Side Position")
@export var container_size_side:Vector2
@export var container_pos_side:Vector2
@export var max_rows:int = 3


#CACHED COMPS
@onready var player_inventory = get_tree().get_first_node_in_group("player")
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
@onready var slots: Array = $ScrollContainer/GridContainer.get_children()
@onready var bg_bottom = $bg_bottom
@onready var bg_side = $bg_side
@onready var inventory_container = $ScrollContainer
@onready var grid_container = $ScrollContainer/GridContainer
@onready var morale_text = $topbar/morale_text
@onready var money_text = $topbar/money_text


@onready var large_view_button = $LargeView/Button
@onready var large_view_slot = $LargeView/InventoryUILarge
@onready var large_view_bg = $LargeView/ButtonBG

#STATE
var data_bk
var bottom_position = true
var large_view_active = false

var is_open = false

func _ready():
	update_topbar()
	
	#connect large view buttons
	large_view_button.pressed.connect(large_view_button_pressed)
	for i in slots:
		i.large_view_clicked.connect(large_view_button_pressed)
		i.dragged.connect(card_dragged)
		i.stop_drag.connect(card_drag_ended)
	event_manager.on_encounter_end.connect(encounter_end)
	event_manager.on_encounter_start.connect(encounter_start)
	reset_large_view()
func encounter_end():
	close()

func encounter_start():
	open()

func add_slot():
	var temp = inventory_slot_scene.instantiate()
	grid_container.add_child(temp)
	slots.append(temp)
	temp.large_view_clicked.connect(large_view_button_pressed)
	temp.dragged.connect(card_dragged)
	temp.stop_drag.connect(card_drag_ended)

func remove_slots(amount):
	var i = 0
	while i < amount:
		i += 1
		slots.back().queue_free()
		slots.remove_at(-1)

func get_slots_cards_list() -> Array[Node]:
	var card_order:Array[Node] = []
	for slot in slots:
		if slot.card != null:
			card_order.append(slot.card)
	return card_order

func update_slots():
	var slot_order: Array[Node] = get_slots_cards_list()
	# Reorder current_cards to match the visual slot order
	# Only if the slot order differs from current_cards
	if slot_order.size() > 0 and slot_order.size() == player_inventory.current_cards.size():
		var needs_reorder = false
		for i in range(slot_order.size()):
			if slot_order[i] != player_inventory.current_cards[i]:
				needs_reorder = true
				break
		if needs_reorder:
			player_inventory.current_cards = slot_order
	#check slot amount
	var slots_to_remove = 0
	while player_inventory.current_cards.size() > slots.size():
		add_slot()
	for i in range(slots.size()):
		#update slots with items
		if (player_inventory.current_cards.size() > i):
			slots[i].update(player_inventory.current_cards[i])
		else:
			if i > min_slots:
				slots_to_remove += 1
			else:
				slots[i].update(null)
	remove_slots(slots_to_remove)
	#if bottom adjust column amount
	if (bottom_position):
		grid_container.columns = slots.size()
	else:
		var new_columns = ceili(float(slots.size())/float(max_rows))
		grid_container.columns = new_columns
		#Scrollbar
	$ScrollContainer._call_deferred_update_hints()
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("Inventory")):
		if (is_open):
			close()
		else:
			open()
	#Sets cursor to not be blocked (visual)
	if Input.get_current_cursor_shape()==CURSOR_FORBIDDEN:
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)

#Drag and drop not outside window
func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_DRAG_BEGIN:
		data_bk = get_viewport().gui_get_drag_data()
	if what == Node.NOTIFICATION_DRAG_END:
		if not is_drag_successful():
			if data_bk:
				data_bk.item_visual.show()
				data_bk = null

func update_position(bottom):
	bottom_position = bottom
	if bottom_position:
		inventory_container.size = container_size_bottom
		inventory_container.position = container_pos_bottom
		inventory_container.custom_minimum_size = container_size_bottom
		grid_container.size = container_size_bottom
		bg_side.visible = false
	else:
		inventory_container.size = container_size_side
		inventory_container.position = container_pos_side
		inventory_container.custom_minimum_size = container_size_side
		grid_container.size = container_size_side
		bg_bottom.visible = false
	open()
	
func open():
	inventory_container.visible = true
	is_open = true
	reset_large_view()
	update_topbar()
	
func close():
	reset_large_view()
	inventory_container.visible = false
	is_open = false

func update_topbar():
	money_text.text = str(player_inventory.current_money)
	morale_text.text = str(player_inventory.current_morale)

#region Large View
func toggle_large_view(card):
	if large_view_active:
		
		large_view_button.visible = false
		large_view_slot.visible = false
		large_view_bg.start_fade(-large_view_bg_fade_speed)
		large_view_active = false
		for i in slots:
			i.large_view_clicked.disconnect(set_new_large_view)
			i.large_view_clicked.connect(large_view_button_pressed)
	else:
		
		large_view_button.visible = true
		large_view_slot.visible = true
		large_view_bg.start_fade(large_view_bg_fade_speed)
		if card != null:
			large_view_slot.update(card)
		large_view_active = true
		for i in slots:
			i.large_view_clicked.disconnect(large_view_button_pressed)
			i.large_view_clicked.connect(set_new_large_view)

func large_view_button_pressed(card = null):
	toggle_large_view(card)

func set_new_large_view(card):
	large_view_slot.update(card)

func reset_large_view():
	large_view_bg.stop_fade()
	large_view_slot.visible = false
	large_view_button.visible = false
	if (large_view_active):
		toggle_large_view(null)
	large_view_active = false
#endregion

#region Ability UI
func card_dragged(card):
	player_inventory.set_card_drag(card)
func card_drag_ended(card):
	player_inventory.stop_card_drag()
