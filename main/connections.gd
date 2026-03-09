extends Node2D

@export var line_scene : PackedScene

var preview_line : Node2D = null
var subpreview_line : Node2D = null
var preview_from_port : Port
var preview_inputoutput : bool

var connections : Array[Connection]

func add_connection(connection : Connection):
	connection.ID = connections.size()
	connections.append(connection)
	History.commit(HistoryConnectionCreate.new(
		connection.ID,
		connection.from.ID,
		connection.from_port,
		connection.to.ID,
		connection.to_port,
		connection.line.line.points,
		connection.color,
		connection.connection_state
	))

func get_connection_instance(id : int) -> Connection:
	return connections[id]

func _ready() -> void:
	ConnectionManager.connection_started.connect(on_connection_started)
	ConnectionManager.connection_ended.connect(on_connection_ended)
	GlobalNodes.connections = self

func quick_create_line(
		points : PackedVector2Array,
		color : Color
	):
	
	var line : Node2D = line_scene.instantiate()
	line.line.points = points
	line.outline.points = points
	line.line.default_color = color
	
	return line

func on_connection_started(from : Node, port : int, inputoutput : bool):
	preview_from_port = from.ports_in[port]\
						if inputoutput else\
						from.ports_out[port]
	preview_inputoutput = inputoutput
	
	preview_line = line_scene.instantiate()
	preview_line.line.add_point(preview_from_port.position + from.global_position)
	add_child(preview_line)
	subpreview_line = line_scene.instantiate()
	subpreview_line.line.add_point(preview_from_port.position + from.global_position)
	subpreview_line.line.add_point(Constants.snap_to_grid(get_global_mouse_position()))
	subpreview_line.line.add_point(Constants.snap_to_grid(get_global_mouse_position()))
	subpreview_line.line.add_point(Constants.snap_to_grid(get_global_mouse_position()))
	add_child(subpreview_line)

func update_subpreview_line():
	var mousex := Vector2(Constants.snap_to_grid(get_global_mouse_position()).x, subpreview_line.line.get_point_position(0).y)
	var mousey := Vector2(subpreview_line.line.get_point_position(0).x, Constants.snap_to_grid(get_global_mouse_position()).y)
	var mouse_pos := Constants.snap_to_grid(get_global_mouse_position())
	subpreview_line.line.set_point_position(1, mousex if preview_from_port.axis == Constants.Axis.HORIZONTAL else mousey)
	subpreview_line.line.set_point_position(2, mouse_pos)
	subpreview_line.line.set_point_position(3, mouse_pos)

func update_subpreview_line_final(to : Node, port : Port):
	var first_point_pos : Vector2 = subpreview_line.line.get_point_position(0)
	var port_pos : Vector2 = port.position + to.global_position
	if port.axis == preview_from_port.axis and preview_line.line.get_point_count() <= 1:
		var midpoint := Constants.snap_to_grid((first_point_pos + port_pos) / 2)
		if port.axis == Constants.Axis.HORIZONTAL:
			subpreview_line.line.set_point_position(0, first_point_pos)
			subpreview_line.line.set_point_position(1, Vector2(midpoint.x, first_point_pos.y))
			subpreview_line.line.set_point_position(2, Vector2(midpoint.x, port_pos.y))
			subpreview_line.line.set_point_position(3, port_pos)
		else:
			subpreview_line.line.set_point_position(0, first_point_pos)
			subpreview_line.line.set_point_position(1, Vector2(first_point_pos.x, midpoint.y))
			subpreview_line.line.set_point_position(2, Vector2(port_pos.x, midpoint.y))
			subpreview_line.line.set_point_position(3, port_pos)
		return
	if port.axis == Constants.Axis.HORIZONTAL:
		if first_point_pos.y != port_pos.y:
			subpreview_line.line.set_point_position(1, Vector2(first_point_pos.x, port_pos.y))
		if first_point_pos.x != port_pos.x:
			subpreview_line.line.set_point_position(2, port_pos)
			subpreview_line.line.set_point_position(3, port_pos)
	else:
		if first_point_pos.x != port_pos.x:
			subpreview_line.line.set_point_position(1, Vector2(port_pos.x, first_point_pos.y))
		if first_point_pos.y != port_pos.y:
			subpreview_line.line.set_point_position(2, port_pos)
			subpreview_line.line.set_point_position(3, port_pos)
	

func on_connection_ended(to : Node, port : int, inputoutput : bool):
	var preview_to_port = to.ports_in[port]\
						if inputoutput else\
						to.ports_out[port]
	
	
	add_joint_final(to, preview_to_port)
	preview_line.outline.points = preview_line.line.points
	var connection = Connection.new(
		ConnectionManager.preview_from if inputoutput else to, 
		ConnectionManager.preview_port if inputoutput else port, 
		to if inputoutput else ConnectionManager.preview_from, 
		port if inputoutput else ConnectionManager.preview_port, 
		preview_line)
	
	add_connection(connection)
	preview_line = null
	subpreview_line.queue_free()
	subpreview_line = null

func _unhandled_input(event: InputEvent) -> void: # mouse click
	if ConnectionManager.currently_creating_preview: 
		if event is InputEventMouseButton:
			if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
				add_joint()
			if event.button_index == MouseButton.MOUSE_BUTTON_RIGHT and event.pressed:
				preview_line.queue_free()
				preview_line = null
				subpreview_line.queue_free()
				subpreview_line = null
				ConnectionManager.connection_quit.emit()

func _input(event: InputEvent) -> void: # mouse move
	if ConnectionManager.currently_creating_preview:
		if event is InputEventMouseMotion:
			if ConnectionManager.hovering_port != null:
				update_subpreview_line_final(ConnectionManager.hovering_port.parent, ConnectionManager.hovering_port)
			else:
				update_subpreview_line()

func add_joint():
	var first_point_pos : Vector2 = subpreview_line.line.get_point_position(0)
	var second_point_pos: Vector2 = subpreview_line.line.get_point_position(1)
	var third_point_pos : Vector2 = subpreview_line.line.get_point_position(2)
	if first_point_pos != second_point_pos:
		preview_line.line.add_point(second_point_pos)
		subpreview_line.line.set_point_position(0, second_point_pos)
	if first_point_pos != third_point_pos:
		preview_line.line.add_point(third_point_pos)
		subpreview_line.line.set_point_position(0, third_point_pos)

func add_joint_final(to : Node, port : Port):
	var first_point_pos : Vector2 = subpreview_line.line.get_point_position(0)
	var port_pos : Vector2 = port.position + to.global_position
	if port.axis == preview_from_port.axis and preview_line.line.get_point_count() <= 1:
		var midpoint := Constants.snap_to_grid((first_point_pos + port_pos) / 2)
		if port.axis == Constants.Axis.HORIZONTAL:
			preview_line.line.add_point(Vector2(midpoint.x, first_point_pos.y))
			preview_line.line.add_point(Vector2(midpoint.x, port_pos.y))
			preview_line.line.add_point(port_pos)
		else:
			preview_line.line.add_point(Vector2(first_point_pos.x, midpoint.y))
			preview_line.line.add_point(Vector2(port_pos.x, midpoint.y))
			preview_line.line.add_point(port_pos)
		return
	if port.axis == Constants.Axis.HORIZONTAL:
		if first_point_pos.y != port_pos.y:
			preview_line.line.add_point(Vector2(first_point_pos.x, port_pos.y))
		if first_point_pos.x != port_pos.x:
			preview_line.line.add_point(port_pos)
	else:
		if first_point_pos.x != port_pos.x:
			preview_line.line.add_point(Vector2(port_pos.x, first_point_pos.y))
		if first_point_pos.y != port_pos.y:
			preview_line.line.add_point(port_pos)
