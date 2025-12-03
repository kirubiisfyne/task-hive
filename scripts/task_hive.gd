@tool
extends Control

@onready var hive_label := $Hive
@onready var hive_name_label := $"Hive Name"

@export var align_left := true

func _ready() -> void:
	_set_layout_direction(align_left)

	$"Hive Name".text = self.name

func _set_layout_direction(left: bool) -> void:
	if left:
		hive_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		hive_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	else:
		hive_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		hive_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

func load_board() -> void:
	KanbanManager.current_board = KanbanManager.load_board(self.name)
	get_tree().change_scene_to_file("res://scenes/hive.tscn")

func _on_button_down() -> void:
	load_board()
