extends Node2D
#PARAMS
@export var die_scene:PackedScene
@export_group("Spawn")
@export var pulse_power:float = 100
@export var pulse_range:float = 100
@export var collision_delay: float = 0.2
@export var min_dist_to_edge:float = 100
@export_group("Visuals")
@export_subgroup("Sprites")
@export var sweet_sprite:Texture
@export var sour_sprite:Texture
@export var spicy_sprite:Texture
@export var hearty_sprite:Texture
@export var fresh_sprite:Texture

#CACHED COMPS
@onready var pan_collider = $Pan/CollisionPolygon2D
@onready var pan_center = $Pan/center
@onready var event_manager = get_tree().get_first_node_in_group("event_manager")

#STATE
var dice:Array[Node]
var highlighted_dice: Array[RigidBody2D]

func finish_dish():
	for die in dice:
		die.stop_movement()
	event_manager.dish_finish_animation_done()

func spawn_die(flavour, value, card):
	#get point dropped inside static body or closest point if outside
	var mouse_pos = get_global_mouse_position()
	var spawn_pos
	if !Geometry2D.is_point_in_polygon(mouse_pos, get_global_polygon(pan_collider)):
		var point_on_line: Vector2 = closest_point_on_polygon(mouse_pos, get_global_polygon(pan_collider))
		var distance = point_on_line.distance_to(pan_center.global_position)
		var rel_dist = min_dist_to_edge/distance
		spawn_pos = point_on_line.lerp(pan_center.position, rel_dist)
	else:
		#if point is close to edge of pan, move more inside
		var point_on_line = closest_point_on_polygon(mouse_pos, get_global_polygon(pan_collider))
		var dist_to_edge:float = (point_on_line - mouse_pos).length()
		if dist_to_edge < min_dist_to_edge:
			var distance = point_on_line.distance_to(pan_center.global_position)
			var rel_dist = min_dist_to_edge/distance
			spawn_pos = point_on_line.lerp(pan_center.position, rel_dist)
		else:
			spawn_pos = mouse_pos
	#create circular pulse to clear area of other dice
	point_explosion(spawn_pos)
	
	
	#instantiate dice in that position without collision
	var new_die = die_scene.instantiate()
	add_child(new_die)
	card.dice.append(new_die)
	
	new_die.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	new_die.freeze = true
	new_die.global_position = spawn_pos
	new_die.wait_activate_collision(collision_delay)
	#set sprite based on flavour
	match flavour:
		"sweet":
			new_die.change_sprite(sweet_sprite)
		"sour":
			new_die.change_sprite(sour_sprite)
		"spicy":
			new_die.change_sprite(spicy_sprite)
		"hearty":
			new_die.change_sprite(hearty_sprite)
		"fresh":
			new_die.change_sprite(fresh_sprite)
	new_die.flavour = flavour
	#set highlight
	new_die.display_number(value)
	new_die.start_highlight()

func reset_highlights(card):
	if card == null:
		return
	for i in card.dice:
		i.stop_highlight()
		i.stop_number()

func destroy_dice(card):
	for die in card.dice:
		die.destroy()

func point_explosion(point):
	for die in dice:
		var dir: Vector2 = die.global_position - point
		var dist: float = dir.length()
		if dist < pulse_range:
			die.apply_impulse(dir.normalized() * pulse_power)

func get_global_polygon(collider: CollisionPolygon2D) -> PackedVector2Array:
	var local_poly = collider.polygon
	var global_poly := PackedVector2Array()
	global_poly.resize(local_poly.size())
	for i in local_poly.size():
		global_poly[i] = collider.global_transform * local_poly[i]
	return global_poly

func closest_point_on_polygon(point: Vector2, polygon: PackedVector2Array) -> Vector2:
	if polygon.is_empty():
		return point
	var closest := point
	var min_dist_sq := INF
	
	var n := polygon.size()
	for i in n:
		var a := polygon[i]
		var b := polygon[(i + 1) % n]
		
		var p_on_seg := Geometry2D.get_closest_point_to_segment(point, a, b)
		var dist_sq := point.distance_squared_to(p_on_seg)
		
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			closest = p_on_seg
			
	return closest
