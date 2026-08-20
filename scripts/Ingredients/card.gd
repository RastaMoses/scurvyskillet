extends Node

var stats:Resource
var uses:int
var price:int

func _ready() -> void:
	$Preview.queue_free()

func set_stats(resource:Resource):
	print (stats)
	stats = resource
	uses = stats.uses
