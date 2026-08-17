extends Node2D

@export_group("Requirements")
@export var req_nutrition:int
@export var req_sweet:int
@export var req_sour:int
@export var req_spicy:int
@export var req_hearty:int
@export var req_fresh:int


func on_success():
	pass

func on_partial_failure():
	pass

func on_failure():
	pass
