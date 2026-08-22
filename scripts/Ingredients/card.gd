extends Node

var stats:Resource
var base_stats:Resource
var price:int
var dice:Array[RigidBody2D]


func _ready() -> void:
	$Preview.queue_free()

func set_stats(resource:Resource):
	stats = resource.duplicate(true)
	base_stats = resource

func reset_to_base_stats():
	var temp = stats.uses
	stats = base_stats
	stats.uses = temp
