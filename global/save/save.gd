extends Node


func save():
	var file_save := FileSave.new()
	
	for node in GlobalNodes.nodes.get_children():
		var node_save := NodeSave.new()
		node_save.scene_path = node.scene_file_path
		print(node_save.scene_path)
		node_save.position = node.position
		node_save.properties = node.get_child(0).node.properties
		file_save.nodes.append(node_save)
	for connection in ConnectionManager.connections:
		var connection_save := ConnectionSave.new()
		connection_save.from_path = GlobalNodes.nodes.get_path_to(connection.from)
		connection_save.to_path = GlobalNodes.nodes.get_path_to(connection.to)
		connection_save.from_port = connection.from_port
		connection_save.to_port = connection.to_port
		connection_save.points = connection.line.points
		file_save.connections.append(connection_save)
	
	var err = ResourceSaver.save(file_save, "res://save.tres")
	if err != OK:
		print("Save failed:", err)
