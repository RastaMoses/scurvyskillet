extends Control

@export var move_x:int = 8
@export var move_wait_time:float = 1

var waiting = false
var moved = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move()

func move():
	if waiting:
		return
	waiting = true
	await get_tree().create_timer(move_wait_time).timeout
	waiting = false
	if moved:
		global_position.x -= move_x
		moved = false
	else:
		global_position.x += move_x
		moved = true
