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

# Optional: Add delete functionality
func delete_card() -> void:
	if board_data and card_id in board_data.cells:
		# Remove from board data
		board_data.cells.erase(card_id)

		# Remove from column's card list
		for col in board_data.columns:
			if card_id in col["cards"]:
				col["cards"].erase(card_id)
				break

		# Save and remove node
		KanbanManager.save_current_board()
		queue_free()
