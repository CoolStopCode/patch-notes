# connection.gd
class_name Connection
extends RefCounted   # important: not a Node

var from: Node2D
var from_port : int
var to: Node2D
var to_port : int
var line: Line2D

func _init(_from: Node2D, _from_port : int, _to: Node2D, _to_port : int, _line: Line2D):
	from = _from
	from_port = _from_port
	to = _to
	to_port = _to_port
	line = _line

	# listen to both ends
	from.actuate_output.connect(_on_endpoint_gone)
	from.tree_exiting.connect(_on_endpoint_gone)
	to.tree_exiting.connect(_on_endpoint_gone)

func update():
	line.set_point_position(0, from.global_position)
	line.set_point_position(1, to.global_position)

func _on_endpoint_gone():
	queue_free()

func _on_actuate_output():
	to.receive_input()
	
func queue_free():
	if is_instance_valid(line):
		line.queue_free()
