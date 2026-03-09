class_name HistoryConnectionCreate
extends HistoryAction

var id : int
var from_id: int
var from_port : int
var to_id: int
var to_port : int
var points : PackedVector2Array
var color : Color
var connection_state : Constants.ConnectionState

func undo():
	var connection : Connection = GlobalNodes.connections.get_connection_instance(id)
	connection.free_connection()
	if GlobalNodes.inspector.connection_inspector.active_connection == connection:
		GlobalNodes.inspector.connection_inspector.close()

func redo():
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
	
	GlobalNodes.connections.connections[id] = connection

func _init(
		_id : int,
		_from_id : int,
		_from_port : int,
		_to_id : int,
		_to_port : int, 
		_points : PackedVector2Array,
		_color : Color,
		_connection_state : Constants.ConnectionState
	) -> void:
	name = "Connection Create"
	id = _id
	from_id = _from_id
	from_port = _from_port
	to_id = _to_id
	to_port = _to_port
	points = _points
	color = _color
	connection_state = _connection_state
