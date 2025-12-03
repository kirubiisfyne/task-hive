extends Resource
class_name KanbanData

@export var columnys: Array[Dictionary] = []  # e.g., [{"name": "To Do", "cards": [card_id1, card_id2]}]
@export var cells: Dictionary = {}  # Key: card ID (e.g., "card1"), Value: {"title": "Task", "description": "...", "status": "To Do", ...}
@export var cell_order: Dictionary = {}  # Key: column name, Value: ordered list of card IDs for sorting
# Add any other fields you need, e.g., @export var project_name: String = ""
