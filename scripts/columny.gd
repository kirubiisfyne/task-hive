extends Control

const CELL := preload("res://scenes/components/cell.tscn")
const COLUMNY := preload("res://scenes/components/columny.tscn")

@onready var columny_title: LineEdit = $"Columny Title"
@onready var cell_container: Container = $"Cell Container"
@onready var add_cell_button: Button = $"Cell Container/New Cell"

var board_data: KanbanData

func _ready() -> void:
	board_data = KanbanManager.current_board

	columny_title.text_submitted.connect(_on_text_changed)

	if add_cell_button:
		add_cell_button.pressed.connect(_on_add_cell_pressed)

	if cell_container and not cell_container.is_connected("child_order_changed", Callable(self, "_on_cell_container_child_order_changed")):
		cell_container.connect("child_order_changed", Callable(self, "_on_cell_container_child_order_changed"))

func _on_cell_container_child_order_changed():
	_keep_add_button_last()

func _keep_add_button_last():
	if add_cell_button and cell_container:
		cell_container.move_child(add_cell_button, cell_container.get_child_count() - 1)

func set_columny_data(_columny_title: String, cell_ids: Array, data: KanbanData) -> void:
	board_data = data
	columny_title.text = _columny_title
	self.name = _columny_title

	if cell_container:
		for child in cell_container.get_children():
			if child != add_cell_button:
				child.queue_free()

		for cell_id in cell_ids:
			if cell_id in board_data.cells:
				var cell_instance = CELL.instantiate()
				cell_instance.set_cell_data(board_data.cells[cell_id], cell_id, board_data)
				cell_container.add_child(cell_instance)

		cell_container.show()
		_keep_add_button_last()

func _on_text_changed(new_text: String) -> void:
	if cell_container:
		cell_container.show()

	self.name = new_text

	for col in board_data.columnys:
		if col["name"] == columny_title.text:
			col["name"] = new_text
			break
	KanbanManager.save_current_board()

	var c = COLUMNY.instantiate()
	get_parent().add_child(c)

func _on_add_cell_pressed() -> void:
	if not cell_container or not board_data:
		return

	var cell_id = KanbanManager.generate_cell_id()

	var cell_data = {
		"title": "New cell",
		"description": "",
		"status": self.name
	}

	board_data.cells[cell_id] = cell_data

	for col in board_data.columnys:
		if col["name"] == self.name:
			col["cells"].append(cell_id)
			break

	var cell_instance = CELL.instantiate()
	cell_instance.set_cell_data(cell_data, cell_id, board_data)
	cell_container.add_child(cell_instance)

	KanbanManager.save_current_board()

	_keep_add_button_last()

# New: Handle drops for moving cells between columns
func _can_drop_data(at_position: Vector2, data) -> bool:
	# Accept only cells from other columns (not this one)
	return data is Control and data.has_method("set_cell_data") and data != self and data.get_parent() != cell_container

func _drop_data(at_position: Vector2, data) -> void:
	var cell = data as Control
	if not cell or not cell.card_id or not board_data:
		return
	
	# Remove from old column's data
	var old_parent = cell.get_parent()
	if old_parent and old_parent != cell_container:
		for col in board_data.columnys:
			if cell.card_id in col["cells"]:
				col["cells"].erase(cell.card_id)
				break
	
	# Add to this column's data
	for col in board_data.columnys:
		if col["name"] == self.name:
			col["cells"].append(cell.card_id)
			break
	
	# Move the cell node to this container
	if old_parent:
		old_parent.remove_child(cell)
	cell_container.add_child(cell)
	cell_container.move_child(cell, cell_container.get_child_count() - 2)  # Before add button
	
	# Update cell status
	if cell.card_id in board_data.cells:
		board_data.cells[cell.card_id]["status"] = self.name
	
	# Save and refresh layout
	KanbanManager.save_current_board()
	_keep_add_button_last()
	
	print("Moved cell " + cell.card_id + " to column " + self.name)
