class_name PlayerInventory
extends Inventory


#PARAMS
@export_group("Values")
@export var current_money:int
@export var current_morale:int
@export_group("UI")
@export var morale_text:RichTextLabel
@export var money_text:RichTextLabel

func _ready() -> void:
	update_topbar()
	ui.update_slots()
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
