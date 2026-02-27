extends Node

var default_path : String
func save():
	if not default_path: return
	save_to(default_path)

func save_to(path : String):
	print("STARTING SAVE")
	var file_save := FileSave.new()
	
	var id_map := {}  # Node -> ID
	var id_counter := 0
	
	for node in GlobalNodes.nodes.get_children():
		var node_save := NodeSave.new()
		node_save.scene_path = node.scene_file_path
		node_save.position = node.position
		node_save.properties = node.get_child(0).properties
		node_save.node_state = node.get_child(0).node_state
		node_save.id = id_counter
		id_map[node.get_child(0)] = id_counter
		id_counter += 1
		file_save.nodes.append(node_save)
	for connection in ConnectionManager.connections:
		if connection.freed:
			continue
		var connection_save := ConnectionSave.new()
		connection_save.from_id = id_map.get(connection.from, -1)
		connection_save.to_id = id_map.get(connection.to, -1)
		connection_save.from_port = connection.from_port
		connection_save.to_port = connection.to_port
		connection_save.connection_state = connection.connection_state
		connection_save.points = connection.line.line.points
		connection_save.color = connection.color
		file_save.connections.append(connection_save)
	
	var temp_path := path.substr(0, path.length() - 2) + ".tres"

	var err = ResourceSaver.save(file_save, temp_path)
	if err != OK:
		print(temp_path)
		print("Save failed:", err)
		return

	var dir = DirAccess.open(temp_path.get_base_dir())
	dir.rename(temp_path.get_file(), path.get_file())

	default_path = path
	
	print("FINISHED SAVE")
