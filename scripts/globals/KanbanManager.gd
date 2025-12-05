extends Node

const HEAD_PATH = "user://data/kanban_head.tres" # Path to your head .tres file
var head_data: KanbanHead
var current_board: KanbanData  # Reference to the currently loaded board

func _ready():
	_init_user_folder()
	_load_or_create_head()

func _init_user_folder():
	# Ensure user://data/ exists
	var dir := DirAccess.open("user://")
	if not dir.dir_exists("data"):
		dir.make_dir("data")

func _load_or_create_head():
	if ResourceLoader.exists(HEAD_PATH):
		head_data = ResourceLoader.load(HEAD_PATH)
		print("Loaded KanbanHead with boards: ", head_data.boards)
	else:
		print("KanbanHead not found. Creating a fresh one at ", HEAD_PATH)
		head_data = KanbanHead.new()
		head_data.boards = {}  # make sure it's a dictionary
		ResourceSaver.save(head_data, HEAD_PATH)

func load_board(board_name: String) -> KanbanData:
	if not head_data:
		push_error("KanbanManager: head_data is NULL! Cannot load board.")
		return null

	if board_name in head_data.boards:
		var path = head_data.boards[board_name]

		if ResourceLoader.exists(path):
			current_board = ResourceLoader.load(path)
			print("Loaded board: " + current_board.resource_name)
			return current_board
		else:
			push_error("Board file missing: " + path)
	else:
		push_error("Board name does not exist in head: " + board_name)

	return null

func save_current_board():
	if not current_board or not head_data:
		push_error("save_current_board() failed: current_board or head_data is NULL")
		return

	for board_name in head_data.boards:
		if head_data.boards[board_name] == current_board.resource_path:
			ResourceSaver.save(current_board, head_data.boards[board_name])
			print("Saved board: ", board_name)
			return

func get_board_names() -> Array:
	if not head_data:
		return []
	return head_data.boards.keys()

func generate_cell_id() -> String:
	return "cell_" + str(randi()) + "_" + str(Time.get_unix_time_from_system())

func create_board(board_name: String, board_path: String):
	if not head_data:
		push_error("create_board() failed: head_data is NULL!")
		return

	head_data.boards[board_name] = board_path

	var new_board := KanbanData.new()
	ResourceSaver.save(new_board, board_path)
	ResourceSaver.save(head_data, HEAD_PATH)

	print("Created new board: ", board_name)
