extends Node2D

@export var line_scene : PackedScene

var preview_line : Line2D = null
var preview_line_last_point : Vector2

func _ready() -> void:
	ConnectionManager.connection_started.connect(on_connection_started)
	ConnectionManager.connection_ended.connect(on_connection_ended)

func on_connection_started(from : Node, port : int, _inputoutput : bool):
	preview_line = line_scene.instantiate()
	ConnectionManager.preview_from = from
	ConnectionManager.preview_port = port
	if ConnectionManager.preview_inputoutput:
		preview_line.add_point(from.ports_in[port] + from.global_position)
	else:
		preview_line.add_point(from.ports_out[port] + from.global_position)
	add_joint_to_line()
	add_child(preview_line)

func on_connection_ended(to : Node, port : int, inputoutput : bool):
	if preview_line.get_point_count() < 4:
		var midpoint : float = (preview_line.get_point_position(0).x + preview_line.get_point_position(preview_line.get_point_count() - 1).x) / 2
		preview_line.add_point(Vector2(midpoint, preview_line.get_point_position(0).y), 1)
		preview_line.add_point(Vector2(midpoint, preview_line.get_point_position(preview_line.get_point_count() - 1).y), 1)
	elif to.ports_in[port].y + to.global_position.y != preview_line.get_point_position(preview_line.get_point_count() - 1).y:
		preview_line.add_point(Vector2(0, 0))
	
	print(preview_line.get_point_count())
	var connection = Connection.new(
		ConnectionManager.preview_from if inputoutput else to, 
		ConnectionManager.preview_port if inputoutput else port, 
		to if inputoutput else ConnectionManager.preview_from, 
		port if inputoutput else ConnectionManager.preview_port, 
		preview_line)
	preview_line = null
	connection.update()
	ConnectionManager.connections.append(connection)

func _unhandled_input(event: InputEvent) -> void:
	if preview_line:
		print(preview_line.get_point_count())
	if ConnectionManager.currently_creating_preview:
		if event is InputEventMouseMotion:
			var mousepos : Vector2 = Constants.snap_to_grid(get_global_mouse_position())
			var horizontal : bool = abs(mousepos.x - preview_line_last_point.x) > abs(mousepos.y - preview_line_last_point.y)
			if preview_line.get_point_count() == 2: horizontal = true
			if horizontal:
				preview_line.set_point_position(preview_line.get_point_count() - 1, 
				Vector2(mousepos.x, preview_line_last_point.y))
			else:
				preview_line.set_point_position(preview_line.get_point_count() - 1, 
				Vector2(preview_line_last_point.x, mousepos.y))
		if event is InputEventMouseButton:
			if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
				add_joint_to_line()

func add_joint_to_line():
	print("AAAAAAA")
	var locked_pos := preview_line.get_point_position(
		preview_line.get_point_count() - 1
	)

	preview_line_last_point = locked_pos

	# now create the next moving point
	preview_line.add_point(locked_pos)
