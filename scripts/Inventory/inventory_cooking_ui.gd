extends Control

#PARAMS

#CACHED COMPS
@onready var inventory = get_node("/root/root/Player/Inventory")
@onready var slots: Array = $ScrollContainer/GridContainer.get_children()

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
	visible = true
	is_open = true
	
func close():
	visible = false
	is_open = false
