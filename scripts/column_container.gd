@tool
extends Container
class_name ColumnyContainer

@export var columny_width: float = 200.0:
	set(value):
		columny_width = value
		queue_sort()

@export var spacing: float = 10.0:
	set(value):
		spacing = value
		queue_sort()

@export var items_per_row: int = 3:
	set(value):
		items_per_row = value
		queue_sort()

@export var stagger_offset: float = 30.0:
	set(value):
		stagger_offset = value
		queue_sort()

const COLUMNY_SCENE := preload("res://scenes/components/columny.tscn")

func _ready():
	populate_columnys(KanbanManager.current_board)

	if not is_connected("child_order_changed", Callable(self, "_on_child_order_changed")):
		connect("child_order_changed", Callable(self, "_on_child_order_changed"))

func _on_child_order_changed():
	queue_sort()

func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		_arrange_columnys()

func _keep_new_columny_last():
	for columny in get_children():
		if not columny.cell_container.visible:
			move_child(columny, get_child_count() - 1)
			print("Moved " + columny.name + " columny to last.")
	

func _arrange_columnys():
	if not is_inside_tree():
		return

	var index := 0
	var row_heights = []

	for child in get_children():
		if not child is Control:
			continue

		var col: int = index / items_per_row
		var row: int = index % items_per_row

		while row_heights.size() <= row:
			row_heights.append(0.0)

		var x = col * (columny_width + spacing)
		var y = 0.0
		for r in range(row):
			y += row_heights[r] + spacing
		if col % 2 == 1:
			y += stagger_offset

		child.position = Vector2(x, y)
		child.custom_minimum_size.x = columny_width
		child.size.x = columny_width

		var child_height = child.get_combined_minimum_size().y
		row_heights[row] = max(row_heights[row], child_height)

		index += 1

	var total_height = 0.0
	for h in row_heights:
		total_height += h + spacing
	total_height -= spacing

	var last_row = row_heights.size() - 1
	if last_row >= 0 and (index - 1) % items_per_row % 2 == 1:
		total_height += stagger_offset

	custom_minimum_size = Vector2(items_per_row * (columny_width + spacing) - spacing, total_height)

func populate_columnys(board_data: KanbanData) -> void:
	for child in get_children():
		child.queue_free()
	
	# Instantiate and add columnys
	for col_data in board_data.columnys:
		var col_instance = COLUMNY_SCENE.instantiate()
		col_instance.name = col_data["name"]
		
		# Add to tree FIRST
		add_child(col_instance)
		move_child(col_instance, get_child_count() + 1)
		
		# Wait for one frame
		await get_tree().process_frame
		
		# NOW set data
		col_instance.set_columny_data(col_data["name"], col_data["cells"], board_data)
	queue_sort()
	
	var empty_columny = COLUMNY_SCENE.instantiate()
	add_child(empty_columny)
