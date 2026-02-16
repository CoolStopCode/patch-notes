extends Control


func _on_file_id_pressed(id: int) -> void:
	if id == 0:
		Save.save()


func _on_edit_id_pressed(_id: int) -> void:
	pass # Replace with function body.
