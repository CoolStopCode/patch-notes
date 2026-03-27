extends Control

@export var node_inspector : Node
@export var connection_inspector : Node

func _ready() -> void:
	GlobalNodes.inspector = self

func open_node_inspector():
	node_inspector.open()
	connection_inspector.close()

func close_node_inspector():
	node_inspector.close()

func update_node_inspector():
	node_inspector.update()
	connection_inspector.close()

func open_connection_inspector(connection : Connection):
	node_inspector.close()
	connection_inspector.open(connection)

func update_connection_inspector():
	node_inspector.close()
	connection_inspector.update()
