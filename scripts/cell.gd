extends Control

# References to UI elements
@onready var title_edit: LineEdit = $"Background/Cell Name"
@onready var description_edit: LineEdit = $"Background/Description"

var card_id: String
var board_data: KanbanData

func _ready() -> void:
	# Connect signals ONCE
	if title_edit:
		title_edit.text_submitted.connect(_on_title_submitted)
		# Also connect text_submitted for real-time updates (optional)
		title_edit.text_submitted.connect(_on_title_text_submitted)
	
	if description_edit:
		description_edit.text_submitted.connect(_on_description_submitted)
		# Also connect text_submitted for real-time updates (optional)
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

# Save title changes when Enter is pressed
func _on_title_submitted(new_text: String) -> void:
	_save_title(new_text)

# Save title changes in real-time
func _on_title_text_submitted(new_text: String) -> void:
	_save_title(new_text)

func _save_title(new_text: String) -> void:
	if board_data and card_id in board_data.cells:
		board_data.cells[card_id]["title"] = new_text
		KanbanManager.save_current_board()

# Save description changes when Enter is pressed
func _on_description_submitted(new_text: String) -> void:
	_save_description(new_text)

# Save description changes in real-time
func _on_description_text_submitted(new_text: String) -> void:
	_save_description(new_text)

func _save_description(new_text: String) -> void:
	if board_data and card_id in board_data.cells:
		board_data.cells[card_id]["description"] = new_text
		KanbanManager.save_current_board()

# Drag-and-drop support
func _get_drag_data(at_position: Vector2):
	# Provide drag data (the cell node itself)
	set_drag_preview(_create_drag_preview())
	return self  # Return the cell node for identification

func _create_drag_preview() -> Control:
	# Create a simple preview (e.g., a duplicate of the cell)
	var preview = duplicate()
	preview.modulate = Color(1, 1, 1, 0.5)  # Semi-transparent
	return preview

# Optional: Handle input for starting drag (e.g., on mouse down)
func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Start drag on click (or use a handle)
		force_drag(self, _create_drag_preview())

# Optional: Add delete functionality (updated for consistency)
func delete_card() -> void:
	if board_data and card_id in board_data.cells:
		# Remove from board data
		board_data.cells.erase(card_id)

		# Remove from column's cell list (updated to match columnys/cells)
		for col in board_data.columnys:
			if card_id in col["cells"]:
				col["cells"].erase(card_id)
				break

		# Save and remove node
		KanbanManager.save_current_board()
		queue_free()
