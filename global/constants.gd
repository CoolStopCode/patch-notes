extends Node

@export var GRID_SIZE := Vector2(4, 4)
@export var NODE_LIST : NodeList = load("res://nodes/node_list.tres")
@export var DEFAULT_CONNECTION_COLOR : Color = Color("394a50")
@export var global_time : float = 0.0

enum NodeState {
	NORMAL,
	PASS,
	BROKEN
}
enum ConnectionState {
	NORMAL,
	BROKEN
}
enum Axis { HORIZONTAL, VERTICAL }

func snap_to_grid(pos) -> Vector2:
	return snapped(pos, GRID_SIZE)

func clear_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func _process(delta: float) -> void:
	global_time += delta
