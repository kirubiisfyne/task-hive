extends Node

const HEAD_PATH = "res://data/kanban_head.tres" # Path to your head .tres file

var head_data: KanbanHead
var current_board: KanbanData  # Reference to the currently loaded board

func _ready():
	# Load the head file on startup
	if ResourceLoader.exists(HEAD_PATH):
		print(ResourceLoader.load(HEAD_PATH).boards)
		head_data = ResourceLoader.load(HEAD_PATH)

	else:
		push_error("KanbanHead resource not found at " + HEAD_PATH)
		# Optionally create a new one if missing, but since you're making it in editor, this shouldn't happen

# Load a board by name (from the head file)
func load_board(board_name: String) -> KanbanData:
	if board_name in head_data.boards:
		var path = head_data.boards[board_name]
		if ResourceLoader.exists(path):
			current_board = ResourceLoader.load(path)
			print("Kanban.gd: " + current_board.resource_name)
			return current_board
		else:
			push_error("Board file not found: " + path)
	return null

# Save the current board back to its file
func save_current_board():
	if current_board and head_data:
		# Find the path for the current board (assuming you track the current board name)
		for board_name in head_data.boards:
			if head_data.boards[board_name] == current_board.resource_path:
				ResourceSaver.save(current_board, head_data.boards[board_name])
				break

# Get a list of all board names
func get_board_names() -> Array:
	return head_data.boards.keys()

# In KanbanManager.gd
func generate_cell_id() -> String:
	print("KanbanManager.gd: Generated Cell ID!")
	return "cell_" + str(randi()) + "_" + str(Time.get_unix_time_from_system())

# Optional: Create a new board (if you want runtime creation, but you said editor-only)
func create_board(board_name: String, board_path: String):
	head_data.boards[board_name] = board_path
	var new_board = KanbanData.new()  # Assumes KanbanData is your board class
	ResourceSaver.save(new_board, board_path)
	ResourceSaver.save(head_data, HEAD_PATH)  # Save the updated head
