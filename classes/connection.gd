# connection.gd
class_name Connection
extends RefCounted   # important: not a Node

var from: Node2D
var from_port : int
var to: Node2D
var to_port : int
var line: Line2D
var freed := false

var pulse_tween: Tween

# from is always output, to is always input
func _init(_from: Node2D, _from_port : int, _to: Node2D, _to_port : int, _line: Line2D):
	from = _from
	from_port = _from_port
	to = _to
	to_port = _to_port
	line = _line

	# listen to both ends
	from.actuate_output.connect(_on_actuate_output)
	
	from.tree_exiting.connect(_on_endpoint_gone)
	from.move.connect(update)
	from.ports_modified.connect(update)
	if from != to:
		to.tree_exiting.connect(_on_endpoint_gone)
		to.move.connect(update)
		to.ports_modified.connect(update)

func update():
	if from.ports_out.size() <= from_port or to.ports_in.size() <= to_port:
		free_connection()
		return
	line.set_point_position(0, from.ports_out[from_port].position + from.global_position)
	if from.ports_out[from_port].axis == Constants.Axis.HORIZONTAL:
		line.set_point_position(1, Vector2(line.get_point_position(1).x, from.ports_out[from_port].position.y + from.global_position.y))
	else:
		line.set_point_position(1, Vector2(from.ports_out[from_port].position.x + from.global_position.x, line.get_point_position(1).y))
	
	line.set_point_position(line.get_point_count() - 1, to.ports_in[to_port].position + to.global_position)
	if from.ports_out[from_port].axis == Constants.Axis.HORIZONTAL:
		line.set_point_position(line.get_point_count() - 2, 
			Vector2(line.get_point_position(line.get_point_count() - 2).x, to.ports_in[to_port].position.y + to.global_position.y)
		)
	else:
		line.set_point_position(line.get_point_count() - 2, 
			Vector2(to.ports_in[to_port].position.x + to.global_position.x, line.get_point_position(line.get_point_count() - 2).y)
		)


func _on_endpoint_gone():
	free_connection()

func _on_actuate_output(_port):
	if from_port != _port:
		return
	pulse()
	to.receive_input()

func pulse():
	if pulse_tween and pulse_tween.is_running():
		line.modulate = Color(1.0, 1.0, 1.0)
		pulse_tween.kill()

	pulse_tween = line.create_tween()
	pulse_tween.set_trans(Tween.TRANS_CIRC)
	pulse_tween.set_ease(Tween.EASE_OUT)

	var base := Color(1.0, 1.0, 1.0)
	var bright := base * 3.0

	pulse_tween.tween_property(line, "modulate", base, 0.4).from(bright)

func free_connection():
	if is_instance_valid(from):
		from.actuate_output.disconnect(_on_actuate_output)
		from.tree_exiting.disconnect(_on_endpoint_gone)
		from.move.disconnect(update)
		from.ports_modified.disconnect(update)

	if is_instance_valid(to) and to != from:
		to.tree_exiting.disconnect(_on_endpoint_gone)
		to.move.disconnect(update)
		to.ports_modified.disconnect(update)

	if pulse_tween and pulse_tween.is_running():
		pulse_tween.kill()

	if is_instance_valid(line):
		line.queue_free()

	from = null
	to = null
	line = null
	pulse_tween = null
	
	freed = true
