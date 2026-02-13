extends Node

@export var GRID_SIZE := Vector2(4, 4)
@export var NODE_LIST : NodeList = load("res://node/node_list.tres")

enum NodeState {
	NORMAL,
	PASS,
	BROKEN
}

func snap_to_grid(pos):
	return snapped(pos, GRID_SIZE)

func clear_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
