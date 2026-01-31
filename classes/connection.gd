# connection.gd
class_name Connection
extends RefCounted   # important: not a Node

var from: Node2D
var from_port : int
var to: Node2D
var to_port : int
var line: Line2D

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
	if from != to:
		to.tree_exiting.connect(_on_endpoint_gone)
		to.move.connect(update)
	

func update():
	line.set_point_position(0, from.ports_out[from_port] + from.global_position)
	line.set_point_position(1, Vector2(line.get_point_position(1).x, from.ports_out[from_port].y + from.global_position.y))
	
	line.set_point_position(line.get_point_count() - 1, to.ports_in[to_port] + to.global_position)
	line.set_point_position(line.get_point_count() - 2, 
		Vector2(line.get_point_position(line.get_point_count() - 2).x, to.ports_in[to_port].y + to.global_position.y)
	)
	
	
	#BETTER SOLUTION:
	#instead of click to create 2 points, click only creates one point, but its locked to 90 degree angles.
	#however, you can click on a port without it being in line with your last point, it will automatically create the points
	#needed to connect your last point and the port using only vertical and horizontal segments. (can also click from port to
	#port with this same thing)


func _on_endpoint_gone():
	queue_free()

func _on_actuate_output():
	pulse()
	
	to.receive_input()

func pulse():
	if pulse_tween and pulse_tween.is_running():
		pulse_tween.kill()

	# ✨ Create new tween
	pulse_tween = line.create_tween()
	pulse_tween.set_trans(Tween.TRANS_CIRC)
	pulse_tween.set_ease(Tween.EASE_OUT)

	var base := line.default_color
	var bright := base * 4.0

	pulse_tween.tween_property(line, "default_color", base, 0.15).from(bright)

func queue_free():
	if is_instance_valid(line):
		line.queue_free()
