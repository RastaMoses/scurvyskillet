extends Control

#PARAMS
@export var inventory_slot_scene:PackedScene
@export var min_slots: int = 10

#CACHED COMPS
@onready var inventory = get_parent()
@onready var slots: Array = $ScrollContainer/GridContainer.get_children()
@onready var bg = $bg
@onready var inventory_container = $ScrollContainer
@onready var grid_container = $ScrollContainer/GridContainer
@onready var morale_text = $topbar/morale_text
@onready var money_text = $topbar/money_text
@onready var large_view_button = $large_view

#STATE
var data_bk

var is_open = false

func _ready():
	close()
	large_view_button.visible = false
	large_view_button.pressed.connect(large_view_button_pressed)
	for i in slots:
		i.large_view_clicked.connect(large_view_button_pressed)

func add_slot():
	var temp = inventory_slot_scene.instantiate()
	grid_container.add_child(temp)
	slots.append(temp)
	temp.large_view_clicked.connect(large_view_button_pressed)

func remove_slots(amount):
	var i = 0
	while i < amount:
		i += 1
		slots.back().queue_free()
		slots.remove_at(-1)

func update_slots():
	var slots_to_remove = 0
	while inventory.current_ingredients.size() > slots.size():
		add_slot()
	for i in range(slots.size()):
		if (inventory.current_ingredients.size() > i):
			slots[i].update(inventory.current_ingredients[i])
		else:
			if i > min_slots:
				slots_to_remove += 1
			else:
				slots[i].update(null)
	remove_slots(slots_to_remove)

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

func open():
	bg.visible = true
	inventory_container.visible = true
	is_open = true
	update_slots()
	
func close():
	bg.visible = false
	inventory_container.visible = false
	is_open = false

func update_topbar():
	money_text.text = inventory.current_money
	morale_text.text = inventory.current_morale
	
func toggle_large_view(ingredient):
	if large_view_button.visible:
		large_view_button.visible = false
		for i in slots:
			i.large_view_clicked.disconnect(set_new_large_view)
			i.large_view_clicked.connect(large_view_button_pressed)
	else:
		large_view_button.visible = true
		if ingredient != null:
			large_view_button.get_child(0).update(ingredient)
		for i in slots:
			i.large_view_clicked.disconnect(large_view_button_pressed)
			i.large_view_clicked.connect(set_new_large_view)
		

func large_view_button_pressed(ingredients):
	toggle_large_view(ingredients)

func set_new_large_view(ingredient):
	large_view_button.get_child(0).update(ingredient)
