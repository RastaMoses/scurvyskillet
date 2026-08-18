extends Control

#PARAMS

#CACHED COMPS
@onready var inventory = get_parent()
@onready var slots: Array = $ScrollContainer/GridContainer.get_children()
@onready var bg = $bg
@onready var inventory_container = $ScrollContainer
@onready var morale_text = $topbar/morale_text
@onready var money_text = $topbar/money_text

#STATE
var data_bk

var is_open = false

func _ready():
	close()

func update_slots():
	for i in range(slots.size()):
		if (inventory.current_ingredients.size() > i):
			slots[i].update(inventory.current_ingredients[i])
		else:
			slots[i].update(null)

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("Inventory")):
		update_slots()
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
	
func close():
	bg.visible = false
	inventory_container.visible = false
	is_open = false

func update_topbar():
	money_text.text = inventory.current_money
	morale_text.text = inventory.current_morale
