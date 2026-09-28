class_name Combination
extends Resource


@export var name:String
@export_multiline() var description:String
@export var types:Array[GlobalEnums.CombinationType]
@export var rarity:GlobalEnums.Rarity
@export_group("Specifics")
@export var relevant_ingredients:Array[Ingredient]
