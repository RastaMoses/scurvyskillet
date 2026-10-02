class_name CombinationDisplay
extends Node

@export var name_label:RichTextLabel
@export var description_label:RichTextLabel
@export var seperator:Control
@export var button:ButtonUI
var combination:Combination
var card_arrays:Array

signal hover_start
signal hover_stop

func _ready() -> void:
	button.start_hover.connect(on_hover_start)
	button.stop_hover.connect(on_hover_stop)

func init_ui(comb, cards):
	card_arrays = cards
	combination = comb
	name_label.text = combination.name
	description_label.text = combination.description
	self.visible = true
func on_hover_start():
	hover_start.emit(combination, card_arrays)

func on_hover_stop():
	hover_stop.emit()
