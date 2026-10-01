class_name ShopUI
extends Control


@export_group("UI Nodes")
@export var drop_area:DropArea
@export var buy_container:Control
@export var buy_round_button:Control
@export var buy_round_foam:Control
@export var leave_button:Control
@export var shop:Shop

#STATE
func _ready() -> void:
	buy_round_button.set_text(str(shop.morale_price))
	leave_button.left_clicked.connect(leave_clicked)
	buy_round_button.left_clicked.connect(buy_round_clicked)

func toggle_buy_round_foam(value):
	buy_round_foam.visible = value

func toggle_interactable():
	var value = shop.interactable
	if !value:
		for i in shop.buy_buttons:
			if i.hide_item:
				for j in i.ui.slots:
					j.large_view_button.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
	else:
		for i in shop.buy_buttons:
			if i.hide_item:
				for j in i.ui.slots:
					j.large_view_button.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	drop_area.toggle_disabled(!value)
	buy_round_button.toggle_disabled(!value)
	leave_button.toggle_disabled(!value)

func leave_clicked():
	shop.end()

func buy_round_clicked():
	shop.buy_morale()
