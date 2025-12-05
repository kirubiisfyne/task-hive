extends ScrollContainer

# Tweakable
const DRAG_THRESHOLD := 12.0   # pixels before we consider the gesture a drag
const EDGE_CANCEL := 6.0       # ignore tiny jitter

# State
var touch_start_pos := {}
var touch_started_control := {}
var touch_moved := {}

func _gui_input(event):
	# Support both touch and mouse drags
	if event is InputEventScreenTouch:
		_handle_touch_press(event)
		return
	if event is InputEventScreenDrag:
		_handle_touch_drag(event)
		return
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
		return
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MouseButton.MOUSE_BUTTON_LEFT):
		# treat mouse motion as drag for desktop testing
		var fake = InputEventScreenDrag.new()
		fake.position = event.position
		fake.relative = event.relative
		fake.index = 0
		_handle_touch_drag(fake)
		return

func _handle_touch_press(event: InputEventScreenTouch) -> void:
	var id = str(event.index)
	if event.pressed:
		# record start
		touch_start_pos[id] = event.position
		touch_moved[id] = false
		# find which control (if any) is under the initial touch
		var ctrl = get_viewport().gui_pick(event.position)
		touch_started_control[id] = ctrl
	else:
		# release: clear state
		touch_start_pos.erase(id)
		touch_started_control.erase(id)
		touch_moved.erase(id)

func _handle_touch_drag(event: InputEventScreenDrag) -> void:
	var id = str(event.index)
	# if we don't know this touch, act like press
	if not touch_start_pos.has(id):
		touch_start_pos[id] = event.position - event.relative
		touch_moved[id] = false
		touch_started_control[id] = get_viewport().gui_pick(event.position)

	# compute movement from start
	var start = touch_start_pos[id]
	var dist = event.position.distance_to(start)

	# ignore tiny jitter
	if dist < EDGE_CANCEL:
		return

	# if already flagged as moved or exceeds threshold, treat as drag
	if dist >= DRAG_THRESHOLD:
		touch_moved[id] = true

		# Scroll the container by the drag delta.
		# Use relative so it works with both vertical and horizontal scrolling.
		# Invert Y so dragging finger up scrolls down the content (natural feel).
		if event.relative.y != 0:
			_v_scroll_by(-event.relative.y)
		if event.relative.x != 0:
			_h_scroll_by(-event.relative.x)

		# If the drag started on a control (Button / LineEdit / etc.), 
		# prevent the child from receiving further drag events so the scroll wins.
		var started_ctrl = touch_started_control.get(id, null)
		if started_ctrl:
			# consume the event so the control doesn't treat it as a long press/drag
			accept_event()
		else:
			# if not started on a control, do nothing (ScrollContainer will naturally scroll)
			pass

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	# keep desktop behavior: left click press registers normally, dragging handled in mouse motion branch above
	pass

func _v_scroll_by(dy: float) -> void:
	var sb = get_v_scroll_bar()
	if sb:
		sb.value = clamp(sb.value + dy, sb.min_value, sb.max_value)

func _h_scroll_by(dx: float) -> void:
	var sb = get_h_scroll_bar()
	if sb:
		sb.value = clamp(sb.value + dx, sb.min_value, sb.max_value)
