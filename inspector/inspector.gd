extends Control

@export var node_inspector : Node
@export var connection_inspector : Node

func _ready() -> void:
	GlobalNodes.inspector = self

func open_node_inspector(node : Node):
	node_inspector.open(node)
	connection_inspector.close()

func open_connection_inspector(connection : Connection):
	node_inspector.close()
	connection_inspector.open(connection)
