extends Control

@export var scroll_speed: float = 1.0  # Adjust for sensitivity
@export var drag_threshold: float = 10.0

var is_dragging: bool = false
var last_touch_pos: Vector2 = Vector2()
var scroll_offset: Vector2 = Vector2()  # Track manual scroll

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			is_dragging = false
			last_touch_pos = event.position
		else:
			# On release, reset
			is_dragging = false
	
	elif event is InputEventScreenDrag:
		var delta = event.relative
		if not is_dragging:
			if abs(delta.x) > drag_threshold or abs(delta.y) > drag_threshold:
				is_dragging = true
				# Accept the event to block children
				accept_event()
		if is_dragging:
			accept_event()  # Block children during drag
			# Manually scroll the content (assuming a child ScrollContainer or direct offset)
			scroll_offset += delta * scroll_speed
			# If you have a ScrollContainer child, adjust its scroll:
			var scroll_child = get_node("ScrollContainer")  # Replace with your path
			if scroll_child:
				scroll_child.scroll_vertical -= delta.y
				scroll_child.scroll_horizontal -= delta.x
			# Or, if no ScrollContainer, offset the rect_position of scrollable children
			for child in get_children():
				if child is Control and child != scroll_child:
					child.rect_position -= delta * scroll_speed
