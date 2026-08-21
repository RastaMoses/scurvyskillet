extends Node


@onready var event_manager = get_tree().get_first_node_in_group("event_manager")
@onready var item_pool = get_tree().get_first_node_in_group("ingredient_pool")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	event_manager.start_game()
