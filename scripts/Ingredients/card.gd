extends Node

var stats:Ingredient
var temp_stats: Ingredient
var base_stats:Ingredient
var price:int
var dice:Array[RigidBody2D]


func _ready() -> void:
	$Preview.queue_free()

func set_stats(new_stats:Ingredient,resource:Ingredient):
	stats = new_stats.duplicate(true)
	base_stats = resource
	temp_stats = stats.duplicate(true)

func reset_preview():
	stats = temp_stats.duplicate(true)

func set_preview():
	temp_stats = stats.duplicate(true)
	
