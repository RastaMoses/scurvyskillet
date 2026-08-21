extends Node

var stats:Resource
var uses:int
var price:int
var dice:Array[RigidBody2D]

func _ready() -> void:
	$Preview.queue_free()

func set_stats(resource:Resource):
	stats = resource
	uses = stats.uses
