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
	add_cell_button.pressed.connect(_on_add_cell_pressed)
	
func _on_cell_container_child_order_changed():
	_keep_add_button_last()

func _keep_add_button_last():
	if add_cell_button and cell_container:
		cell_container.move_child(add_cell_button, cell_container.get_child_count() - 1)

func set_columny_data(columny_name: String, cell_ids: Array, data: KanbanData) -> void:
	board_data = data
	
	self.name = columny_name
	columny_title.text = columny_name
	
	# Clear existing cells (keep add button)
	if cell_container:
		for child in cell_container.get_children():
			if child != add_cell_button:
				child.queue_free()

		# Add cells from data
		for cell_id in cell_ids:
			if cell_id in board_data.cells:
				var cell_instance = CELL.instantiate()
				cell_container.add_child(cell_instance)
				await get_tree().process_frame  # Wait for cell to be ready
				cell_instance.set_cell_data(board_data.cells[cell_id], cell_id, board_data)

		cell_container.show()
		_keep_add_button_last()

func _on_text_changed(new_text: String) -> void:
	# Store the OLD name before changing anything
	var old_name = self.name
	
	# Update display
	self.name = new_text
	columny_title.text = new_text
	
	if cell_container:
		cell_container.show()
	
	# Check if this is a RENAME or NEW column
	var column_found = false
	
	if board_data and old_name != "":  # If it had a name before
		# This is a RENAME - find and update existing column
		for col in board_data.columnys:
			if col["name"] == old_name:  # Find by OLD name
				col["name"] = new_text
				column_found = true
				break
	
	if not column_found:
		
		if board_data:
			# Add new column to data
			var new_columny = {"name": new_text, "cells": []}
			board_data.columnys.append(new_columny)
			
			# Create another empty column for next entry
			var c = COLUMNY.instantiate()
			get_parent().add_child(c)
	
	# Always save after changes
	if board_data:
		KanbanManager.save_current_board()
		print("columny.gd: Saved changes!")

func _on_add_cell_pressed() -> void:
	if not cell_container or not board_data:
		return

	# Generate unique ID
	var cell_id = KanbanManager.generate_cell_id()

	# Create default cell data
	var cell_data = {
		"title": "New cell",
		"description": "",
		"status": self.name
	}

	# Add to board data
	board_data.cells[cell_id] = cell_data

	# Add to this column's cell list
	for col in board_data.columnys:
		if col["name"] == self.name:
			col["cells"].append(cell_id)
			break

	# Instance the cell
	var cell_instance = CELL.instantiate()
	cell_container.add_child(cell_instance)
	await get_tree().process_frame
	cell_instance.set_cell_data(cell_data, cell_id, board_data)

	# Save changes
	KanbanManager.save_current_board()

	_keep_add_button_last()
