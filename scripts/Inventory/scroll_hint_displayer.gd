extends ScrollContainer

@onready var grid_container = $GridContainer

@export var horizontal_hint_left: Control = null  # e.g. a TextureRect with your up/down graphic
@export var horizontal_hint_right: Control = null
@export var vertical_hint: Control = null  # e.g. a TextureRect with your up/down graphic

@export var margin_top: float = 8.0
@export var margin_bottom: float = 8.0

func _ready() -> void:
	# Disable built-in scroll hints
	scroll_hint_mode = ScrollContainer.SCROLL_HINT_MODE_DISABLED

	# Ensure hints start hidden
	if vertical_hint:
		vertical_hint.visible = false
	if horizontal_hint_left:
		horizontal_hint_left.visible = false
	if horizontal_hint_right:
		horizontal_hint_right.visible = false

	# Connect to size changes so we can update hint visibility
	resized.connect(_on_size_changed)
	get_v_scroll_bar().value_changed.connect(_on_scroll_changed)
	get_h_scroll_bar().value_changed.connect(_on_scroll_changed)
	minimum_size_changed.connect(_on_size_changed)
	child_entered_tree.connect(_on_child_tree_changed)
	child_exiting_tree.connect(_on_child_tree_changed)
	# Initial update
	_call_deferred_update_hints()
	

func _on_size_changed() -> void:
	_call_deferred_update_hints()

func _on_child_tree_changed(_node: Node) -> void:
	# Child added/removed: wait one frame so sizes are computed
	_call_deferred_update_hints()

func _on_scroll_changed(_new_value: float) -> void:
	_call_deferred_update_hints()

func _call_deferred_update_hints() -> void:
	# Defer to next frame so child sizes are up to date
	_update_hints.call_deferred()

func _update_hints() -> void:
	if vertical_hint:
		var can_scroll_v: bool = _can_scroll_vertical()
		vertical_hint.visible = can_scroll_v
		if can_scroll_v:
			var v_scroll: VScrollBar = get_v_scroll_bar()
			var at_top: bool = v_scroll.value <= v_scroll.min_value + 0.01
			var at_bottom: bool = v_scroll.value >= v_scroll.max_value - 0.01

			# Optional: swap textures based on position
			# if vertical_hint is a TextureRect:
			#   var tr := vertical_hint as TextureRect
			#   if at_top: tr.texture = down_only_texture
			#   elif at_bottom: tr.texture = up_only_texture
			#   else: tr.texture = up_down_texture
			vertical_hint.position = Vector2(
				size.x - vertical_hint.size.x - margin_bottom,
				margin_top
			)
	var can_scroll_h: bool = _can_scroll_horizontal()
	if can_scroll_h:
		var h_scroll: HScrollBar = get_h_scroll_bar()
		var at_left: bool = h_scroll.value <= h_scroll.min_value + 0.01
		var at_right: bool = h_scroll.value >= (h_scroll.max_value - h_scroll.page) - 0.01
		if horizontal_hint_left:
			horizontal_hint_left.visible = not at_left
		# Right hint: show when we can scroll right (i.e., NOT at right edge)
		if horizontal_hint_right:
			horizontal_hint_right.visible = not at_right
	else:
		if horizontal_hint_left:
			horizontal_hint_left.visible = false
		if horizontal_hint_right:
			horizontal_hint_right.visible = false
func _can_scroll_vertical() -> bool:
	var content_height: float = 0.0
	if get_child_count() > 0:
		var child: Control = get_child(0) as Control
		if child:
			content_height = child.get_rect().size.y

	return content_height > size.y


func _can_scroll_horizontal() -> bool:
	var content_width: float = 0.0
	if get_child_count() > 0:
		var child: Control = get_child(0) as Control
		if child:
			content_width = child.get_rect().size.x

	return content_width > size.x
