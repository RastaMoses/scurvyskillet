extends Node

#PARAMS
@export_group("Maps Difficulty")
@export var maps_0:Array[PackedScene]
@export var maps_1:Array[PackedScene]
@export var maps_2:Array[PackedScene]
#CACHED
@onready var random = RandomNumberGenerator.new()


#STATE
var current_map
var map_array

func _ready() -> void:
	map_array = [maps_0,maps_1,maps_2]
	

func pick_random_map(difficulty):
	var new_map
	var maps = map_array[difficulty]
	var rand = random.randi_range(0,maps.size()-1)
	new_map = maps[rand]
	return new_map

func load_map(map):
	if (get_child_count() != 0):
		for i in get_children():
			remove_child(i)
	current_map = map.instantiate()
	add_child(current_map)
	current_map.populate_map()
	current_map.set_available_encounters()

func start_game():
	await get_tree().process_frame
	load_map(pick_random_map(0))
