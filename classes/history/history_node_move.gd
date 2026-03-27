class_name HistoryNodeMove
extends HistoryAction

var ids : Array[int]
var delta : Vector2

func undo():
	for id in ids:
		GlobalNodes.nodes.get_node_instance(id).position -= delta
		GlobalNodes.nodes.get_node_instance(id).move.emit()

func redo():
	for id in ids:
		GlobalNodes.nodes.get_node_instance(id).position += delta
		GlobalNodes.nodes.get_node_instance(id).move.emit()

func _init(_ids : Array[int], _delta : Vector2) -> void:
	name = "Node Move"
	ids = _ids
	delta = _delta
