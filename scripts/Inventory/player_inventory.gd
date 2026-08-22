class_name PlayerInventory
extends Inventory

#PARAMS
@export_group("Values")
@export var current_money:int
@export var current_morale:int

func add_money(new_value):
	current_money += new_value
	ui.update_topbar()

func add_morale(new_value):
	current_morale += new_value
	ui.update_topbar()
