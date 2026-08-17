extends Node
#PARAMS
@export_group("Values")
@export var nutrition:int
@export_subgroup("Flavour")
@export var sweet:int
@export var sour:int
@export var spicy:int
@export var hearty:int
@export var fresh:int
@export_subgroup("Immortal Ghoulash")
@export var ig_nutrition:int
@export var ig_sweet:int
@export var ig_sour:int
@export var ig_spicy:int
@export var ig_hearty:int
@export var ig_fresh:int
@export_group("Uses")
@export var unlimited: bool = false
@export var uses: int
@export_group("Special Abilities")
@export var abilities: Array[String]
@export_group("Tags")
@export var tags: Array[String]

#CACHED COMPS

#STATE
var inv_index:int

func get_texture():
	var texture = $TextureRect.texture
	return texture
