extends Control  # Or Button if you prefer

# References to UI elements
@onready var title_edit: LineEdit = $"Background/Cell Name"
@onready var description_edit: LineEdit = $"Background/Description"

var card_id: String
var board_data: KanbanData
var is_dragging = false  # Track if we're in a drag state

func _ready() -> void:
	# Connect signals ONCE
	if title_edit:
		title_edit.text_submitted.connect(_on_title_submitted)
		title_edit.text_submitted.connect(_on_title_text_submitted)
	
	if description_edit:
		description_edit.text_submitted.connect(_on_description_submitted)
		description_edit.text_submitted.connect(_on_description_text_submitted)

# Called to set up the card with data
func set_cell_data(data: Dictionary, id: String, data_ref: KanbanData) -> void:
	card_id = id
	board_data = data_ref

	# Populate UI
	if title_edit:
		title_edit.text = data.get("title", "")
	
	if description_edit:
		var desc = data.get("description", "")
		description_edit.text = desc
		
		await get_tree().process_frame

# Save title changes
func _on_title_submitted(new_text: String) -> void:
	_save_title(new_text)

func _on_title_text_submitted(new_text: String) -> void:
	_save_title(new_text)

func _save_title(new_text: String) -> void:
	if board_data and card_id in board_data.cells:
		board_data.cells[card_id]["title"] = new_text
		KanbanManager.save_current_board()

# Save description changes
func _on_description_submitted(new_text: String) -> void:
	_save_description(new_text)

func _on_description_text_submitted(new_text: String) -> void:
	_save_description(new_text)

func _save_description(new_text: String) -> void:
	if board_data and card_id in board_data.cells:
		board_data.cells[card_id]["description"] = new_text
		KanbanManager.save_current_board()

# Drag-and-drop support (mouse and touch)
func _get_drag_data(at_position: Vector2):
	set_drag_preview(_create_drag_preview())
	return self

func _create_drag_preview() -> Control:
	var preview = duplicate()
	preview.modulate = Color(1, 1, 1, 0.5)
	return preview

var hold_time := 0.25
var dragging := false
var touch_down := false
var hold_timer := 0.0

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		touch_down = true
		hold_timer = 0.0
		dragging = false

	elif event is InputEventScreenTouch and not event.pressed:
		touch_down = false
		if dragging:
			dragging = false
		return

	elif event is InputEventScreenDrag and not dragging:
		if abs(event.relative.y) > abs(event.relative.x):
			touch_down = false
			hold_timer = 0.0
			return

		hold_timer += event.speed.length() / 3000.0

		if hold_timer >= hold_time:
			_start_drag()

	elif event is InputEventScreenDrag and dragging:
		set_drag_preview(_create_drag_preview())
		force_drag(self, _create_drag_preview())
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_drag()
		else:
			dragging = false

func _start_drag():
	var vp = get_viewport()

	# Prevent double-drag initialization
	if vp.gui_is_dragging():
		return

	if dragging:
		return

	dragging = true
	touch_down = false

	var preview = _create_drag_preview()
	set_drag_preview(preview)
	force_drag(self, preview)



# Optional: Add delete functionality
func delete_card() -> void:
	if board_data and card_id in board_data.cells:
		board_data.cells.erase(card_id)
		for col in board_data.columnys:
			if card_id in col["cells"]:
				col["cells"].erase(card_id)
				break
		KanbanManager.save_current_board()
		queue_free()
