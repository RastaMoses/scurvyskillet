extends Control

@export var icon:TextureRect
@export var label:RichTextLabel
@export var button:Button
@export var textures:Array[Texture]
@export var icon_bg_negative:TextureRect
@export var icon_bg_combination:TextureRect
@onready var large_card = get_tree().get_first_node_in_group("card_large_view")
@onready var reward_screen:RewardScreen = get_tree().get_first_node_in_group("reward_screen")

func set_money(amount):
	if amount > 0:
		label.text = "+" + str(amount)
	elif amount < 0:
		label.text = str(amount)
	icon.texture = textures[0]

func set_morale(amount):
	if amount > 0:
		label.text = "+" + str(amount)
	elif amount < 0:
		label.text = str(amount)
	icon.texture = textures[1]

func toggle_icon_bg_negative(value):
	icon_bg_negative.visible = value
func toggle_icon_bg_combination(value):
	icon_bg_combination.visible = value

func _on_money_slot_button_pressed() -> void:
	large_card.cancel_large_view_pressed()


func _on_money_slot_button_mouse_entered() -> void:
	reward_screen.set_hover_combination(self)

func _on_money_slot_button_mouse_exited() -> void:
	reward_screen.stop_hover_combination(self)
