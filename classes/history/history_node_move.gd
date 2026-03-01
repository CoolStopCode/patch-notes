class_name HistoryNodeMove
extends HistoryAction

var id : int
var from : Vector2
var to : Vector2

func undo():
	GlobalNodes.nodes.get_node_instance(id).position = from

func redo():
	GlobalNodes.nodes.get_node_instance(id).position = to

func _init(_id, _from, _to) -> void:
	id = _id
	from = _from
	to = _to
