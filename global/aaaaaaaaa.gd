extends Node2D

@export var LINE_SCENE : PackedScene

var preview_line : Line2D = null
var active_node : BaseNode
var active_port : int
var active_inputoutput : bool

func start_preview(node: BaseNode, port: int, inputoutput: bool):
	cancel_preview()

	active_node = node
	active_port = port
	active_inputoutput = inputoutput

	preview_line = LINE_SCENE.instantiate()
	add_child(preview_line)

	preview_line.add_point(node.global_position)
	preview_line.add_point(node.global_position)

func finalize(node: BaseNode, port: int, inputoutput: bool):
	if preview_line == null:
		return

	# must be opposite directions
	if inputoutput == active_inputoutput:
		cancel_preview()
		return

	var from_node : BaseNode
	var to_node : BaseNode
	var from_port : int
	var to_port : int

	if active_inputoutput:
		from_node = active_node
		from_port = active_port
		to_node = node
		to_port = port
	else:
		from_node = node
		from_port = port
		to_node = active_node
		to_port = active_port

	var line := preview_line
	preview_line = null

	var connection := Connection.new(
		from_node,
		from_port,
		to_node,
		to_port,
		line
	)
	connection.update()

	cancel_state_only()

func cancel_preview():
	if preview_line:
		preview_line.queue_free()
	cancel_state_only()

func cancel_state_only():
	preview_line = null
	active_node = null
	active_port = -1
	active_inputoutput = false

func _process(_delta):
	if preview_line:
		preview_line.set_point_position(
			1,
			get_global_mouse_position()
		)
