extends Control

@onready var buy_container = $BuyButtons
@onready var buy_round_button = $BuyRound/Button
@onready var buy_round_highlight = $BuyRound/HighlightSprite
@onready var buy_round_foam = $BuyRound/FoamSprite
@onready var sell_highlight = $SellBox/Highlight
@onready var moral_price_text = $BuyRound/MoralePrice
@onready var shop = get_parent()

#STATE
func _ready() -> void:
	buy_round_button.mouse_entered.connect(show_buy_round_highlight)
	buy_round_button.mouse_exited.connect(hide_buy_round_highlight)
	moral_price_text.text = str(shop.morale_price)

func toggle_buy_round_foam(value):
	buy_round_foam.visible = value

func show_buy_round_highlight():
	if shop.morale_sold_out:
		return
	buy_round_highlight.visible = true
func hide_buy_round_highlight():
	buy_round_highlight.visible = false

func toggle_sell_highlight(value):
	sell_highlight.visible = value


func _on_drop_area_mouse_exited() -> void:
	toggle_sell_highlight(false)
