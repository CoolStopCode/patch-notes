extends Node

func load_save():
	var file_save : FileSave = load("res://save.tres")
	
	Constants.clear_children(GlobalNodes.nodes)
	Constants.clear_children(GlobalNodes.connections)
	ConnectionManager.connections = []
	
	var id_map := {}
	
	for node in file_save.nodes:
		var node_instance : Node = load(node.scene_path).instantiate()
		node_instance.position = node.position
		node_instance.get_child(0).properties = node.properties
		GlobalNodes.nodes.add_child(node_instance)
		id_map[node.id] = node_instance.get_child(0)
	for connection in file_save.connections:
		var line : Line2D = load("res://node/connection/line.tscn").instantiate()
		line.points = connection.points
		GlobalNodes.connections.add_child(line)
		
		var from_node = id_map.get(connection.from_id)
		var to_node = id_map.get(connection.to_id)
		print(from_node, to_node)
		var connection_instance := Connection.new(
			from_node,
			connection.from_port,
			to_node,
			connection.to_port,
			line
		)
		ConnectionManager.connections.append(connection_instance)
