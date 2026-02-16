extends Node


func save():
	var file_save := FileSave.new()
	
	for node in GlobalNodes.nodes.get_children():
		var node_save := NodeSave.new()
		node_save.scene_path = node.scene_file_path
		node_save.position = node.position
		node_save.properties = node.get_child(0).node.properties
		file_save.nodes.append(node_save)
	file_save.connections = ConnectionManager.connections
	
	var err = ResourceSaver.save(file_save, "res://save.tres")
	if err != OK:
		print("Save failed:", err)
