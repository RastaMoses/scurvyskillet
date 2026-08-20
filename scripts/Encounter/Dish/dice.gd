extends RigidBody2D

#PARAMS
@export var random_power:Vector2
@export var max_speed = 300
@export var highlight_duration:float = 5
#CACHED COMPS
@onready var collision_shape = $CollisionShape2D
@onready var sprite = $Sprite2D
@onready var highlight_sprite = $highlight
@onready var random = RandomNumberGenerator.new()

#STATE
var move_dir
var move_power
var highlight_time:float
var highlighted:bool = false

#Signals

func start_move():
	var rand_power = random.randf_range(random_power.x,random_power.y)
	var rand_dir = Vector2(random.randf_range(-1,1),random.randf_range(-1,1))
	linear_velocity = rand_dir * random_power

func wait_activate_collision(wait_time):
	await get_tree().create_timer(wait_time).timeout
	freeze = false
	start_move()

func change_sprite(texture):
	sprite.texture = texture

func stop_movement():
	linear_velocity = Vector2.ZERO
	freeze = true

func _process(delta: float) -> void:
	if linear_velocity.length() > max_speed:
		linear_velocity *= 0.9
	if highlighted:
		highlight_time -= delta
		highlight_sprite.self_modulate.a = highlight_time/highlight_duration
		

func start_highlight():
	highlighted = true
	highlight_time = highlight_duration
	highlight_sprite.visible = true

func stop_highlight():
	highlighted = false
	highlight_time = 0
	highlight_sprite.visible = false
