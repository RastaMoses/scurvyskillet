extends RigidBody2D

#PARAMS

#CACHED COMPS
@onready var collision_shape = $CollisionShape2D
@onready var sprite = $Sprite2D

#STATE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func wait_activate_collision(wait_time):
	await get_tree().create_timer(wait_time).timeout
	freeze = false

func change_sprite(texture):
	sprite = texture
