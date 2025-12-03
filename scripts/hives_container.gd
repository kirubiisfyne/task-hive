@tool
extends Container
class_name HexContainer

@export var hex_width: float = 60.0:
	set(value):
		hex_width = value
		queue_sort()

@export var hex_height: float = 60.0:
	set(value):
		hex_height = value
		queue_sort()

@export var spacing: float = 8.0:
	set(value):
		spacing = value
		queue_sort()

@export var items_per_row: int = 4:
	set(value):
		items_per_row = value
		queue_sort()

# Preloads
const HEXAGON := preload("res://Scenes/Components/task_hive.tscn")

func _ready():
	if not is_connected("child_order_changed", Callable(self, "_on_child_order_changed")):
		connect("child_order_changed", Callable(self, "_on_child_order_changed"))

	load_hives()
func _on_child_order_changed():
	queue_sort()

func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		_arrange_hex()
	if what == NOTIFICATION_CHILD_ORDER_CHANGED:
		_keep_add_button_last()
		queue_sort()

func _keep_add_button_last():
	var add_button = $"Add Task"
	if add_button:
		move_child(add_button, get_child_count() - 1)

func _arrange_hex():
	if not is_inside_tree():
		return

	var index := 0

	for child in get_children():
		if not child is Control:
			continue

		# Column-based layout
		var col: int = index % items_per_row
		var row: int = index / items_per_row

		# Horizontal and vertical position with separate spacing
		var x = col * (hex_width * 0.75 + spacing)
		var y = row * (hex_height + spacing)

		# Offset every other column
		if col % 2 == 1:
			y += hex_height * 0.5 + (spacing * 0.5)

		# Adjust for RTL by flipping around container width
		if layout_direction == Control.LAYOUT_DIRECTION_RTL:
			# total width of all columns minus half hex for the staggered last column
			var total_cols = min(items_per_row, get_child_count())
			var total_width = total_cols * (hex_width * 0.75 + spacing) + hex_width * 0.25
			x = total_width - (x + hex_width)


		# Apply position and size
		child.position = Vector2(x, y)
		child.custom_minimum_size = Vector2(hex_width, hex_height)
		child.size = Vector2(hex_width, hex_height)

		index += 1

		# After placing all children
		var total_rows = ceil(float(index) / items_per_row)
		# Height: rows * (full height + spacing)
		var total_height = total_rows * (hex_height + spacing)

		# Detect if last column is odd
		var last_col = (index - 1) % items_per_row
		if last_col % 2 == 1:
			total_height += hex_height * 0.5


		# Apply actual size to the container so ScrollContainer can scroll correctly
		custom_minimum_size.y = total_height


func load_hives() -> void:
	for board in KanbanManager.head_data.boards:
		instanciate_hives(board)

func instanciate_hives(hive_name: String) -> void:
	var h = HEXAGON.instantiate()
	h.name = hive_name
	$".".add_child(h)
# Signals
func _on_add_task_button_down() -> void:
	$"../../New Hive".show()

func _on_hive_name_input_text_submitted(new_text: String) -> void:
	instanciate_hives(new_text)

	KanbanManager.create_board(new_text, "res://data/" + new_text + ".tres")
	$"../../New Hive".hide()
