extends RigidBody2D

#PARAMS
@export var random_power:Vector2
#CACHED COMPS
@onready var collision_shape = $CollisionShape2D
@onready var sprite = $Sprite2D
@onready var random = RandomNumberGenerator.new()

#STATE
var move_dir
var move_power

func start_move():
	var rand_power = random.randf_range(random_power.x,random_power.y)
	var rand_dir = Vector2(random.randf_range(0,1),random.randf_range(0,1))
	linear_velocity = rand_dir * random_power

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func wait_activate_collision(wait_time):
	await get_tree().create_timer(wait_time).timeout
	freeze = false
	start_move()

func change_sprite(texture):
	sprite.texture = texture
