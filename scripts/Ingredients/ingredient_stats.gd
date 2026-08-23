class_name Ingredient
extends Resource
#PARAMS
@export var name:String
@export var icon:Texture
@export var tags: Array[GlobalEnums.Tags]
@export var rarity:GlobalEnums.Rarity
@export_multiline() var description:String
@export_group("Values")
@export var nutrition:int
@export_subgroup("Flavour")
@export var sweet:int
var sour:int
@export var spicy:int
@export var hearty:int
@export var fresh:int

#@export_subgroup("Immortal Ghoulash")
#@export var ig_nutrition:int
#@export var ig_sweet:int
#var ig_sour:int
#@export var ig_spicy:int
#@export var ig_hearty:int
#@export var ig_fresh:int
@export_group("Uses")
@export var unlimited_uses: bool = false
@export var uses: int = 1
@export_group("Special Abilities")
@export var abilities: Array[Ability]
@export var undroppable: bool = false
