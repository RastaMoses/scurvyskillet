extends Node

var stats:Ingredient
var committed_stats: Ingredient
var preview_stats: Ingredient
var base_stats:Ingredient
var price:int
var dice:Array[RigidBody2D]
var preview_active:bool = false


func _ready() -> void:
	$Preview.queue_free()

func set_stats(new_stats:Ingredient,resource:Ingredient):
	committed_stats = new_stats.duplicate(true)
	stats = committed_stats
	base_stats = resource
	preview_stats = stats.duplicate(true)

func clear_preview():
	preview_stats = committed_stats.duplicate(true)
	stats = committed_stats

func begin_preview(new_preview_stats:Ingredient):
	preview_stats = new_preview_stats
	stats = preview_stats
	
