extends Control

@export var save_as_dialogue : FileDialog
@export var load_from_dialogue : FileDialog

func _on_file_id_pressed(id: int) -> void:
	if id == 0:
		if not Save.default_path.is_empty():
			Save.save()
		else:
			save_as_dialogue.popup()
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

func _on_dev_id_pressed(id: int) -> void:
	if id == 0:
		Load.load_from("res://dev/dev1.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("undo"):
		if not event.is_action_pressed("redo"):
			History.undo()
		
	if event.is_action_pressed("redo"):
		History.redo()
	
	if event.is_action_pressed("save"):
		if not Save.default_path.is_empty():
			Save.save()
		else:
			save_as_dialogue.popup()
	
	if event.is_action_pressed("save as"):
		save_as_dialogue.popup()

func _on_save_as_file_selected(path: String) -> void:
	Save.save_to(path)

func _on_load_from_file_selected(path: String) -> void:
	Load.load_from(path)

func _ready() -> void:
	var documents_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	save_as_dialogue.current_dir = documents_path
	load_from_dialogue.current_dir = documents_path
	if not Constants.DEV_MODE: $MenuBar/dev.queue_free()
