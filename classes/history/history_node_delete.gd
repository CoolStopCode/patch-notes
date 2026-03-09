class_name HistoryNodeDelete
extends HistoryAction

# TODO: fix this 😭

var node_scene : PackedScene
var id : int
var position : Vector2
var properties : Array[InspectorProperty]

var ids : Array[int]
var from_ids : Array[int]
var from_ports : Array[int]
var to_ids : Array[int]
var to_ports : Array[int]
var colors : Array[Color]
var pointss : Array[PackedVector2Array]
var states : Array[Constants.ConnectionState]

func undo():
	var node = node_scene.instantiate()
	node.creation_drag = false
	node.duplicate_props = false
	node.position = position
	node.properties = properties
	GlobalNodes.nodes.add_child(node)
	GlobalNodes.nodes.nodes[id] = node
	
	var i := 0
	for node_id in ids:
		var from_id = from_ids[i]
		var from_port = from_ports[i]
		var to_id = to_ids[i]
		var to_port = to_ports[i]
		var color = colors[i]
		var points = pointss[i]
		var connection_state = states[i]
		
		var line : Node2D = GlobalNodes.connections.quick_create_line(points, color)
		GlobalNodes.connections.add_child(line)
		
		var connection : Connection = Connection.new(
			GlobalNodes.nodes.get_node_instance(from_id),
			from_port,
			GlobalNodes.nodes.get_node_instance(to_id),
			to_port,
			line
		)
		connection.set_line_color(color)
		connection.connection_state = connection_state
		
		GlobalNodes.connections.connections[node_id] = connection
		i += 1

func redo():
	var node : Node = GlobalNodes.nodes.get_node_instance(id)
	node.queue_free()
	if GlobalNodes.inspector.node_inspector.active_node == node:
		GlobalNodes.inspector.node_inspector.close()

func _init(_node_scene, _id, _position, _properties) -> void:
	name = "Node Delete"
	node_scene = _node_scene
	id = _id
	position = _position
	properties = _properties
	
	for connection in GlobalNodes.connections.connections:
		if connection.to == GlobalNodes.nodes.get_node_instance(id):
			ids.append(connection.ID)
			from_ids.append(connection.from.ID)
			from_ports.append(connection.from_port)
			to_ids.append(connection.to.ID)
			to_ports.append(connection.to_port)
			colors.append(connection.color)
			pointss.append(connection.line.line.points)
			states.append(connection.connection_state)
		elif connection.from == GlobalNodes.nodes.get_node_instance(id):
			ids.append(connection.ID)
			from_ids.append(connection.from.ID)
			from_ports.append(connection.from_port)
			to_ids.append(connection.to.ID)
			to_ports.append(connection.to_port)
			colors.append(connection.color)
			pointss.append(connection.line.line.points)
			states.append(connection.connection_state)
