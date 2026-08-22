extends Node2D

var fade_speed = -1
var fade_active = false
var max_fade = 0.35

var move_duration = 1
var move_active = false
var move_destination:Vector2
var start_location
var time_moved:float

func _ready() -> void:
	start_location = position

func start_fade(speed:float = 1):
	fade_speed = speed * max_fade
	fade_active = true

func stop_fade():
	fade_active = false
	if fade_speed > 0:
		self_modulate.a = max_fade
	else:
		self_modulate.a = 0

func arrive_at_destination():
	move_active = false

func start_moving_to_destination(destination, duration):
	time_moved = 0
	move_duration = duration
	move_destination = destination
	move_active = true

func move_to_last_position(duration = 0):
	if duration == 0:
		global_position = start_location
	else:
		time_moved = 0
		move_duration = duration
		move_destination = start_location
		move_active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#fading
	if fade_active:
		self_modulate.a += delta * fade_speed
		self_modulate.a = clampf(self_modulate.a, 0.0, max_fade)
		if self_modulate.a == 0 or self_modulate.a == max_fade:
			fade_active = false
	#moving
	if move_active:
		time_moved += delta / move_duration
		time_moved = clampf(time_moved,0.0,1.0)
		global_position = lerp(global_position, move_destination, time_moved)
		if time_moved >= 1.0:
			arrive_at_destination()
		#visuals
		var raw_position: Vector2 = global_position 
		# Snap to multiples of your chosen pixel size
		global_position = Vector2(
			round(raw_position.x / 8) * 8,
			round(raw_position.y / 8) * 8
		)
	
