extends Node2D

@export var line_scene : PackedScene

var preview_line : Line2D = null
var preview_line_last_point : Vector2

func _ready() -> void:
	ConnectionManager.connection_started.connect(on_connection_started)
	ConnectionManager.connection_ended.connect(on_connection_ended)

func random_brightness_hsv(color: Color, minimum := 0.6, maximum := 1.4) -> Color:
	var h = color.h
	var s = color.s
	var v = clamp(color.v * randf_range(minimum, maximum), 0.0, 1.0)
	return Color.from_hsv(h, s, v, color.a)

func on_connection_started(from : Node, port : int, _inputoutput : bool):
	preview_line = line_scene.instantiate()
	preview_line.default_color = random_brightness_hsv(preview_line.default_color, 0.7, 1.5)
	ConnectionManager.preview_from = from
	ConnectionManager.preview_port = port
	if ConnectionManager.preview_inputoutput:
		preview_line.add_point(from.ports_in[port] + from.global_position)
	else:
		preview_line.add_point(from.ports_out[port] + from.global_position)
	add_joint_to_line()
	add_child(preview_line)

func on_connection_ended(to : Node, port : int, inputoutput : bool):
	preview_line.add_point(Vector2(0, 0))
	
	var connection = Connection.new(
		ConnectionManager.preview_from if inputoutput else to, 
		ConnectionManager.preview_port if inputoutput else port, 
		to if inputoutput else ConnectionManager.preview_from, 
		port if inputoutput else ConnectionManager.preview_port, 
		preview_line)
	connection.update()
	cleanup_points()
	preview_line = null
	
	ConnectionManager.connections.append(connection)

func cleanup_points():
	for point in range(preview_line.get_point_count() - 2, 0, -1):
		var previous : Vector2 = preview_line.get_point_position(point - 1)
		var current  : Vector2 = preview_line.get_point_position(point)
		var next     : Vector2 = preview_line.get_point_position(point + 1)

		if previous == current:
			preview_line.remove_point(point)
		elif previous.x == current.x and current.x == next.x:
			preview_line.remove_point(point)
		elif previous.y == current.y and current.y == next.y:
			preview_line.remove_point(point)
	if preview_line.get_point_count() < 3:
		var pos1 := preview_line.get_point_position(0)
		var pos2 := preview_line.get_point_position(preview_line.get_point_count() - 1)
		var midpoint := (pos1 + pos2) / 2
		preview_line.add_point(midpoint, 1)
		preview_line.add_point(midpoint, 1)


func _unhandled_input(event: InputEvent) -> void:
	if ConnectionManager.currently_creating_preview: 
		if event is InputEventMouseButton:
			if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
				add_joint_to_line()
			if event.button_index == MouseButton.MOUSE_BUTTON_RIGHT and event.pressed:
				preview_line.queue_free()
				preview_line = null
				ConnectionManager.connection_quit.emit()

func _input(event: InputEvent) -> void:
	if ConnectionManager.currently_creating_preview:
		if event is InputEventMouseMotion:
			var mousepos : Vector2 = Constants.snap_to_grid(get_global_mouse_position())
			preview_line.set_point_position(
				preview_line.get_point_count() - 2, 
				Vector2(mousepos.x, preview_line_last_point.y)
			)
			preview_line.set_point_position(
				preview_line.get_point_count() - 1, 
				Vector2(mousepos.x, mousepos.y)
			)

func add_joint_to_line():
	preview_line_last_point = preview_line.get_point_position(preview_line.get_point_count() - 1)
	

	# now create the next moving point
	preview_line.add_point(preview_line_last_point)
	preview_line.add_point(preview_line_last_point)
	
