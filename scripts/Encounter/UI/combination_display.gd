extends Node

@export var name_label:RichTextLabel
@export var description_label:RichTextLabel
@export var seperator:Control
@export var inventories:Array[Inventory]

func _ready() -> void:
	for inv in inventories:
		inv.init_inventory()
