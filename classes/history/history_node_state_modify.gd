class_name HistoryNodeStateModify
extends HistoryAction

var id : int
var from : Constants.NodeState
var to : Constants.NodeState

func undo():
	GlobalNodes.nodes.get_node_instance(id).node_state = from
	GlobalNodes.inspector.node_inspector.update_state_button()

func redo():
	GlobalNodes.nodes.get_node_instance(id).node_state = to
	GlobalNodes.inspector.node_inspector.update_state_button()

func _init(_id : int, _from : Constants.NodeState, _to : Constants.NodeState) -> void:
	name = "Node State Modify"
	id = _id
	from = _from
	to = _to
