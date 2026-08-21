extends Node2D

var fade_speed = -1
var fade_active = false
var max_fade = 0.35

func _ready() -> void:
	max_fade = self_modulate.a
	self_modulate.a = 0

func start_fade(speed:float = 1):
	fade_speed = speed * max_fade
	fade_active = true

func stop_fade():
	fade_active = false
	if fade_speed > 0:
		self_modulate.a = max_fade
	else:
		self_modulate.a = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !fade_active:
		return
	self_modulate.a += delta * fade_speed
	self_modulate.a = clampf(self_modulate.a, 0.0, max_fade)
	if self_modulate.a == 0 or self_modulate.a == max_fade:
		fade_active = false
