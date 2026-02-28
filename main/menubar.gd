extends Control

@export var save_as_dialogue : FileDialog
@export var load_from_dialogue : FileDialog

func _on_file_id_pressed(id: int) -> void:
	if id == 0:
		Save.save()
	if id == 1:
		save_as_dialogue.popup()
	elif id == 2:
		load_from_dialogue.popup()
	elif id == 3:
		Load.clear_all()

func _on_edit_id_pressed(id: int) -> void:
	if id == 0:
		History.undo()
	if id == 1:
		History.redo()



func _on_save_as_file_selected(path: String) -> void:
	Save.save_to(path)

func _on_load_from_file_selected(path: String) -> void:
	Load.load_from(path)
