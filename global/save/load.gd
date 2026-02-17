extends Node

func load_save():
	var file_save : FileSave = load("res://save.tres")
	
	for node in file_save.nodes:
		print("AAAAA")
		print(node.scene_path)
		print("AAAAAAAA")
		var node_instance : Node = load(node.scene_path).instantiate()
		node_instance.position = node.position
		print(node_instance.get_child(0).node)
		
		node_instance.get_child(0).node.properties = node.properties
		GlobalNodes.nodes.add_child(node_instance)
	for connection in file_save.connections:
		var line := Line2D.new()
		line.points = connection.points
		GlobalNodes.connections.add_child(line)
		var connection_instance := Connection.new(
			get_node(connection.from_path),
			connection.from_port,
			get_node(connection.to_path),
			connection.to_port,
			line
		)
		ConnectionManager.connections.append(connection_instance)
