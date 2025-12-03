extends Resource
class_name KanbanHead

@export var boards: Dictionary = {}  # Key: board name (e.g., "Project Alpha"), Value: path to board .tres (e.g., "res://boards/project_alpha.tres")
@export var board_metadata: Dictionary = {}  # Optional: e.g., {"Project Alpha": {"created": "2023-10-01", "description": "Main project board"}}
