extends RichTextLabel

@export var maximum_font_size: int = 32
@export var minimum_font_size: int = 10
@export var padding: Vector2 = Vector2(8, 8)

var _updating_font_size := false


func _ready() -> void:
	resized.connect(_on_resized)
	call_deferred("fit_font_to_content")


func _on_resized() -> void:
	if not _updating_font_size:
		call_deferred("fit_font_to_content")


func fit_font_to_content() -> void:
	if _updating_font_size:
		return

	_updating_font_size = true

	var font_size := maximum_font_size

	while font_size > minimum_font_size:
		add_theme_font_size_override("normal_font_size", font_size)

		# Allow RichTextLabel to recalculate its layout.
		await get_tree().process_frame

		var content_height := get_content_height()
		var available_height := size.y - padding.y

		if content_height <= available_height:
			break

		font_size -= 8

	add_theme_font_size_override("normal_font_size", font_size)

	_updating_font_size = false
