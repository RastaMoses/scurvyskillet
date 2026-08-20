extends Node2D
#Params
@export var move_time:float = 5.0
@export var pixel_multiple:int = 8

#CACHED
@onready var visuals = $Visuals

#SIGNALS
signal ship_arrived

#STATE
var destination:Vector2
var is_moving = false
var current_pos = 0
var time_moved:float

func start_moving(dock_pos, encounter_index):
	destination = dock_pos.global_position
	current_pos = encounter_index
	time_moved = 0
	is_moving = true

func toggle_ship_visible(value):
	visuals.visible = value

func arrive():
	is_moving = false
	ship_arrived.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_moving:
		time_moved += delta / move_time
		time_moved = clampf(time_moved,0.0,1.0)
		global_position = lerp(global_position, destination, time_moved)
		if time_moved >= 1.0:
			arrive()
	#visuals
	var raw_position: Vector2 = global_position 
	# Snap to multiples of your chosen pixel size
	visuals.global_position = Vector2(
		round(raw_position.x / pixel_multiple) * pixel_multiple,
		round(raw_position.y / pixel_multiple) * pixel_multiple
	)
