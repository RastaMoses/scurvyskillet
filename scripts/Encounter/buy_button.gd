extends Control

@onready var button = $Button

var sell_item:Resource
var sold_out = false
var price:int

signal clicked(buy_button)

func set_item(resource):
	sell_item = resource
	price = sell_item.price

func sell_out():
	sold_out = true
	is_disabled(true)

func _on_button_pressed() -> void:
	clicked.emit(self)

func is_disabled(info):
	button.disabled = info
