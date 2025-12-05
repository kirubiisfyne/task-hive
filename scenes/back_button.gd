extends TextureRect

@export var scene_path:= "res://scenes/garden.tscn"

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(scene_path)
