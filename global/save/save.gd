extends Node


func save():
	var file_save := FileSave.new()
	
	var id_map := {}  # Node -> ID
	var id_counter := 0
	
	for node in GlobalNodes.nodes.get_children():
		var node_save := NodeSave.new()
		node_save.scene_path = node.scene_file_path
		node_save.position = node.position
		node_save.properties = node.get_child(0).node.properties
		node_save.id = id_counter
		id_map[node.get_child(0)] = id_counter
		id_counter += 1
		file_save.nodes.append(node_save)
	print(id_map)
	for connection in ConnectionManager.connections:
		var connection_save := ConnectionSave.new()
		connection_save.from_id = id_map.get(connection.from, -1)
		connection_save.to_id = id_map.get(connection.to, -1)
		print(connection_save.from_id, connection_save.to_id)
		connection_save.from_port = connection.from_port
		connection_save.to_port = connection.to_port
		connection_save.points = connection.line.points
		file_save.connections.append(connection_save)
	
	var err = ResourceSaver.save(file_save, "res://save.tres")
	if err != OK:
		print("Save failed:", err)
