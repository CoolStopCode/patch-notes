class_name HistoryConnectionColorModify
extends HistoryAction

var id : int
var from : Color
var to : Color

func undo():
	GlobalNodes.connections.get_connection_instance(id).set_line_color(from)
	GlobalNodes.inspector.connection_inspector.color_set.emit(from)

func redo():
	GlobalNodes.connections.get_connection_instance(id).set_line_color(to)
	GlobalNodes.inspector.connection_inspector.color_set.emit(to)

func _init(_id : int, _from : Color, _to : ) -> void:
	name = "Connection Color Modify"
	id = _id
	from = _from
	to = _to
