extends Node

var stats:Resource
var uses
var price

func _ready() -> void:
	$Preview.queue_free()

func set_stats(resource):
	stats = resource
	uses = stats.uses
