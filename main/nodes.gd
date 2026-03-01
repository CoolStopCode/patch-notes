extends Node2D

var nodes : Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalNodes.nodes = self

func add_node(node : Node):
	node.ID = nodes.size()
	add_child(node)
	nodes.append(node)

func get_node_instance(id : int) -> Node:
	return nodes[id]
