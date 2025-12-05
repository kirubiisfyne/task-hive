
extends Button

func _ready():
	# Connect the pressed signal to the _on_button_pressed function
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
	# Change to the garden scene
	get_tree().change_scene_to_file("res://Scenes/garden.tscn")
