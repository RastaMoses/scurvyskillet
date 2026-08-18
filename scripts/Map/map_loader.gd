extends Node

#PARAMS
#@export_group("Map Layouts")
@export var maps:Array[PackedScene]
#CACHED
@onready var random = RandomNumberGenerator.new()

#STATE
var current_map

func pick_random_map(difficulty):
	var new_map
	var temp_array:Array
	temp_array.clear()
	for i in maps:
		if i.difficulty == difficulty:
			temp_array.append(i)
	var rand = random.randi_range(0,temp_array.size()-1)
	new_map = temp_array[rand]
	return new_map

func load_map(map):
	if (get_child_count() != 0):
		for i in get_children():
			remove_child(i)
	current_map = map.instantiate()
	add_child(current_map)
	current_map.randomize_encounters()
	current_map.set_available_encounters()

func start_game():
	load_map(pick_random_map(0))
