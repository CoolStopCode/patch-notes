class_name HistoryConnectionStateModify
extends HistoryAction

var id : int
var from : Constants.ConnectionState
var to : Constants.ConnectionState

func undo():
	GlobalNodes.connections.get_connection_instance(id).connection_state = from
	GlobalNodes.inspector.connection_inspector.update_state_button()

func redo():
	GlobalNodes.connections.get_connection_instance(id).connection_state = to
	GlobalNodes.inspector.connection_inspector.update_state_button()

func _init(_id : int, _from : Constants.ConnectionState, _to : Constants.ConnectionState) -> void:
	name = "Connection State Modify"
	id = _id
	from = _from
	to = _to
