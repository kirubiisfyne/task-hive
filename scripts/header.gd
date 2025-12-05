extends TextureRect

@onready var delete_label := $Delete
@onready var titles_node := $Titles
@onready var hive_name := $"Titles/Hive Name"

func _ready():
	# Ensure initial state: show titles, hide delete
	if titles_node:
		titles_node.show()
	if delete_label:
		delete_label.hide()
	
	# Update hive name from database
	update_hive_name()

func update_hive_name():
	var board_name = get_current_board_name()
	if hive_name:
		hive_name.text = board_name
		print("Set hive name to: ", board_name)

func get_current_board_name() -> String:
	if KanbanManager.current_board and KanbanManager.head_data:
		# Find the board name by matching the resource path
		for board_key in KanbanManager.head_data.boards:
			if KanbanManager.head_data.boards[board_key] == KanbanManager.current_board.resource_path:
				return board_key
	return "Default Hive"  # Fallback if not found

func _process(delta):
	# Check if dragging is active globally
	if get_viewport().gui_is_dragging():
		# Hide titles and show delete label during drag
		if titles_node:
			titles_node.hide()
		if delete_label:
			delete_label.show()
	else:
		# Show titles and hide delete label when not dragging
		if titles_node:
			titles_node.show()
		if delete_label:
			delete_label.hide()

# Called when checking if data can be dropped here
func _can_drop_data(at_position: Vector2, data) -> bool:
	# Accept only if data is a cell node (Control with card_id)
	return data is Control and data.has_method("set_cell_data") and data.card_id != ""

# Called when data is dropped
func _drop_data(at_position: Vector2, data) -> void:
	var cell = data as Control
	if not cell or not cell.card_id:
		return
	
	# Get board data from the cell
	var board_data = cell.board_data
	if not board_data:
		push_error("No board data found on cell.")
		return
	
	# Remove from board_data.cells
	if cell.card_id in board_data.cells:
		board_data.cells.erase(cell.card_id)
	
	# Remove from the parent column's cells array (updated for columnys/cells)
	var parent_columny = cell.get_parent().get_parent()  # Assuming cell_container -> columny
	if parent_columny and parent_columny.has_method("set_columny_data"):
		for col in board_data.columnys:
			if col["name"] == parent_columny.name:
				if cell.card_id in col["cells"]:
					col["cells"].erase(cell.card_id)
				break
	
	# Remove the cell node from the scene
	cell.queue_free()
	
	# Save changes
	KanbanManager.save_current_board()
	
	print("Deleted cell: " + cell.card_id)
