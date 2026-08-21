extends RigidBody2D

#PARAMS
@export var pixel_multiple:int = 8
@export var random_power:Vector2
@export var max_speed = 300
@export var highlight_duration:float = 5
@export var highlight_vanish_speed:float = 1
@export var number_duration:float = 10
@export var number_vanish_speed:float = 4 #zero for never
@export_group("Sizzle Anim")
@export var sizzle_scene:PackedScene
@export var sizzle_interval:float = 1
@export var sizzle_spawn_range:Vector2i = Vector2i(0,2)
@export var sizzle_pos_range:Vector2 = Vector2(-10,10)
#CACHED COMPS
@onready var collision_shape = $CollisionShape2D
@onready var sprite = $Visuals/Sprite2D
@onready var highlight_sprite = $Visuals/highlight
@onready var visuals = $Visuals
@onready var number_sprites = $Visuals/Numbers.get_children()
@onready var random = RandomNumberGenerator.new()
@onready var dice_disp = get_parent()

#STATE
var move_dir
var move_power
var highlight_time:float
var number_time:float
var highlighted:bool = false
var number_shown:bool = false
var number
#sizzle
var sizzle_active = true
var sizzle_timer = sizzle_interval

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

func display_number(value):
	number = value
	for i in number_sprites:
		i.visible = false
	start_number()

func stop_movement():
	linear_velocity = Vector2.ZERO
	freeze = true
	sizzle_active = false

func _process(delta: float) -> void:
	if linear_velocity.length() > max_speed:
		linear_velocity *= 0.9
	
	if highlighted:
		highlight_time -= delta
		if highlight_time <= 0:
			if highlight_vanish_speed != 0:
				highlight_sprite.self_modulate.a -= delta * highlight_vanish_speed
			if highlight_sprite.self_modulate.a <= 0:
				highlighted = false
	if number_shown:
		number_time -= delta
		if number_time <= 0:
			if number_vanish_speed != 0:
				number_sprites[number - 1].self_modulate.a -= delta * number_vanish_speed
			if number_sprites[number-1].self_modulate.a <= 0:
				highlighted = false
	if sizzle_active:
		if sizzle_timer >= sizzle_interval:
			sizzle_timer = 0
			for i in random.randi_range(sizzle_spawn_range.x,sizzle_spawn_range.y):
				var anim = sizzle_scene.instantiate()
				anim.anim_int = random.randi_range(0,2)
				dice_disp.add_child(anim)
				anim.global_position = global_position + Vector2(random.randf_range(sizzle_pos_range.x, sizzle_pos_range.y),random.randf_range(sizzle_pos_range.x, sizzle_pos_range.y))
			#anim.global_rotation = linear_velocity.angle()
		sizzle_timer += delta
	#visuals
	var raw_position: Vector2 = global_position 
	# Snap to multiples of your chosen pixel size
	visuals.global_position = Vector2(
		round(raw_position.x / pixel_multiple) * pixel_multiple,
		round(raw_position.y / pixel_multiple) * pixel_multiple
	)

func start_number():
	number_shown = false
	number_time = 0
	number_sprites[number - 1].visible = true
	
func stop_number():
	number_shown = true
	number_time = number_duration
	if number_vanish_speed == 0:
		number_sprites[number - 1].visible = false

func start_visuals():
	start_highlight()
	start_number()

func start_highlight():
	highlighted = true
	highlight_time = highlight_duration
	highlight_sprite.visible = true

func stop_highlight():
	highlighted = false
	highlight_time = 0
	if highlight_vanish_speed != 0:
		highlight_sprite.visible = false
	
