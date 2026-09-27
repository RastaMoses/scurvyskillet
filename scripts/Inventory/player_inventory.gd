class_name PlayerInventory
extends Inventory


#PARAMS
@export_group("Values")
@export var current_money:int
@export var current_morale:int
@export_group("UI")
@export var morale_text:RichTextLabel
@export var money_text:RichTextLabel
@onready var large_view = get_tree().get_first_node_in_group("card_large_view")

func _ready() -> void:
	large_view.init_large_view(ui)
	init_inventory()
	update_topbar()
	ui.open()
	
	event_manager.on_encounter_end.connect(encounter_end)
	event_manager.on_encounter_start.connect(encounter_start)
	
	
func encounter_end():
	ui.close()

func encounter_start():
	ui.open()

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("Inventory")):
		if (ui.is_open):
			ui.close()
		else:
			ui.open()
	#Sets cursor to not be blocked (visual)
	if Input.get_current_cursor_shape()==CURSOR_FORBIDDEN:
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)

func update_topbar():
	money_text.text = str(current_money)
	morale_text.text = str(current_morale)

func add_money(new_value):
	current_money += new_value
	update_topbar()

func add_morale(new_value):
	current_morale += new_value
	update_topbar()

func update_ui():
	ui.update_slots()
	current_cards = ui.get_slots_cards_list()
