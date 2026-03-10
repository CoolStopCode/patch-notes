extends Node

@export var DEV_MODE := false
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

func deep_duplicate_properties(props: Array[InspectorProperty]) -> Array[InspectorProperty]:
	var copy : Array[InspectorProperty] = []
	for p in props:
		copy.append(p.duplicate(true))
	return copy

func _ready() -> void:
	DEV_MODE = OS.has_feature("editor") or "-dev" in OS.get_cmdline_args()
	if DEV_MODE: print("===================\n  DEV MODE ACTIVE  \n===================\n")
