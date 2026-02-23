extends Node2D

@export var line_scene : PackedScene

var preview_line : Line2D = null
var subpreview_line : Line2D = null
var preview_from_port : Port
var preview_inputoutput : bool

func _ready() -> void:
	ConnectionManager.connection_started.connect(on_connection_started)
	ConnectionManager.connection_ended.connect(on_connection_ended)
	GlobalNodes.connections = self

#func random_brightness_hsv(color: Color, minimum := 0.6, maximum := 1.4) -> Color:
	#var h = color.h
	#var s = color.s
	#var v = clamp(color.v * randf_range(minimum, maximum), 0.0, 1.0)
	#return Color.from_hsv(h, s, v, color.a)

func on_connection_started(from : Node, port : int, inputoutput : bool):
	preview_from_port = from.ports_in[port]\
						if inputoutput else\
						from.ports_out[port]
	preview_inputoutput = inputoutput
	
	#preview_line.default_color = random_brightness_hsv(preview_line.default_color, 0.7, 1.5)
	preview_line = line_scene.instantiate()
	preview_line.add_point(preview_from_port.position + from.global_position)
	add_child(preview_line)
	subpreview_line = line_scene.instantiate()
	subpreview_line.add_point(preview_from_port.position + from.global_position)
	subpreview_line.add_point(Constants.snap_to_grid(get_global_mouse_position()))
	subpreview_line.add_point(Constants.snap_to_grid(get_global_mouse_position()))
	subpreview_line.add_point(Constants.snap_to_grid(get_global_mouse_position()))
	add_child(subpreview_line)
	#if ConnectionManager.preview_inputoutput:
		#preview_line.add_point(from.ports_in[port].position + from.global_position)
	#else:
		#preview_line.add_point(from.ports_out[port].position + from.global_position)
	#add_child(preview_line)

func update_subpreview_line():
	var mousex := Vector2(Constants.snap_to_grid(get_global_mouse_position()).x, subpreview_line.get_point_position(0).y)
	var mousey := Constants.snap_to_grid(get_global_mouse_position())
	subpreview_line.set_point_position(1, mousex if preview_from_port.axis == Constants.Axis.HORIZONTAL else mousey)
	subpreview_line.set_point_position(2, mousex if preview_from_port.axis == Constants.Axis.VERTICAL else mousey)
	subpreview_line.set_point_position(3, mousex if preview_from_port.axis == Constants.Axis.VERTICAL else mousey)

func update_subpreview_line_final(to : Node, port : Port):
	var first_point_pos := subpreview_line.get_point_position(0)
	var port_pos : Vector2 = port.position + to.global_position
	if port.axis == preview_from_port.axis and preview_line.get_point_count() <= 1:
		if port.axis == Constants.Axis.HORIZONTAL:
			var midpoint_x := (first_point_pos.x + port_pos.x) / 2
			subpreview_line.set_point_position(0, first_point_pos)
			subpreview_line.set_point_position(1, Vector2(midpoint_x, first_point_pos.y))
			subpreview_line.set_point_position(2, Vector2(midpoint_x, port_pos.y))
			subpreview_line.set_point_position(3, port_pos)
		else:
			var midpoint_y := (first_point_pos.y + port_pos.y) / 2
			subpreview_line.set_point_position(0, first_point_pos)
			subpreview_line.set_point_position(1, Vector2(first_point_pos.x, midpoint_y))
			subpreview_line.set_point_position(2, Vector2(port_pos.x, midpoint_y))
			subpreview_line.set_point_position(3, port_pos)
		return
	if port.axis == Constants.Axis.HORIZONTAL:
		if first_point_pos.y != port_pos.y:
			subpreview_line.set_point_position(1, Vector2(first_point_pos.x, port_pos.y))
		if first_point_pos.x != port_pos.x:
			subpreview_line.set_point_position(2, port_pos)
			subpreview_line.set_point_position(3, port_pos)
	else:
		if first_point_pos.x != port_pos.x:
			subpreview_line.set_point_position(1, Vector2(port_pos.x, first_point_pos.y))
		if first_point_pos.y != port_pos.y:
			subpreview_line.set_point_position(2, port_pos)
			subpreview_line.set_point_position(3, port_pos)
	

func on_connection_ended(to : Node, port : int, inputoutput : bool):
	var preview_to_port = to.ports_in[port]\
						if inputoutput else\
						to.ports_out[port]
	
	#preview_line.add_point(Vector2(0, 0))
	#
	add_joint_final(to, preview_to_port)
	var connection = Connection.new(
		ConnectionManager.preview_from if inputoutput else to, 
		ConnectionManager.preview_port if inputoutput else port, 
		to if inputoutput else ConnectionManager.preview_from, 
		port if inputoutput else ConnectionManager.preview_port, 
		preview_line)
	
	ConnectionManager.connections.append(connection)
	preview_line = null
	subpreview_line.queue_free()
	subpreview_line = null

func cleanup_points():
	pass
	#for point in range(preview_line.get_point_count() - 2, 0, -1):
		#var previous : Vector2 = preview_line.get_point_position(point - 1)
		#var current  : Vector2 = preview_line.get_point_position(point)
		#var next     : Vector2 = preview_line.get_point_position(point + 1)
		#if previous == current:
			#preview_line.remove_point(point)
		#elif previous.x == current.x and current.x == next.x:
			#preview_line.remove_point(point)
		#elif previous.y == current.y and current.y == next.y:
			#preview_line.remove_point(point)
	#if preview_line.get_point_count() < 3:
		#var pos1 := preview_line.get_point_position(0)
		#var pos2 := preview_line.get_point_position(preview_line.get_point_count() - 1)
		#var midpoint : Vector2 = Constants.snap_to_grid((pos1 + pos2) / 2)
		#preview_line.add_point(midpoint, 1)
		#preview_line.add_point(midpoint, 1)


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
	var first_point_pos := subpreview_line.get_point_position(0)
	var second_point_pos := subpreview_line.get_point_position(1)
	var third_point_pos := subpreview_line.get_point_position(2)
	if first_point_pos != second_point_pos:
		preview_line.add_point(second_point_pos)
		subpreview_line.set_point_position(0, second_point_pos)
	if first_point_pos != third_point_pos:
		preview_line.add_point(third_point_pos)
		subpreview_line.set_point_position(0, third_point_pos)

func add_joint_final(to : Node, port : Port):
	var first_point_pos := subpreview_line.get_point_position(0)
	var port_pos : Vector2 = port.position + to.global_position
	if port.axis == preview_from_port.axis and preview_line.get_point_count() <= 1:
		if port.axis == Constants.Axis.HORIZONTAL:
			var midpoint_x := (first_point_pos.x + port_pos.x) / 2
			preview_line.add_point(Vector2(midpoint_x, first_point_pos.y))
			preview_line.add_point(Vector2(midpoint_x, port_pos.y))
			preview_line.add_point(port_pos)
		else:
			var midpoint_y := (first_point_pos.y + port_pos.y) / 2
			preview_line.add_point(Vector2(first_point_pos.x, midpoint_y))
			preview_line.add_point(Vector2(port_pos.x, midpoint_y))
			preview_line.add_point(port_pos)
		return
	if port.axis == Constants.Axis.HORIZONTAL:
		if first_point_pos.y != port_pos.y:
			preview_line.add_point(Vector2(first_point_pos.x, port_pos.y))
		if first_point_pos.x != port_pos.x:
			preview_line.add_point(port_pos)
	else:
		if first_point_pos.x != port_pos.x:
			preview_line.add_point(Vector2(port_pos.x, first_point_pos.y))
		if first_point_pos.y != port_pos.y:
			preview_line.add_point(port_pos)
