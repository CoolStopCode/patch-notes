class_name HistoryNodeMove
extends HistoryAction

var node : Node2D
var from : Vector2
var to : Vector2

func undo():
	node.position = from

func redo():
	node.position = to

func _init(_node, _from, _to) -> void:
	node = _node
	from = _from
	to = _to
