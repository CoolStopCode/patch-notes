class_name HistoryNodeStateModify
extends HistoryAction

var ids : Array[int]
var froms : Array[Constants.NodeState]
var to : Constants.NodeState

func undo():
	for i in range(ids.size()):
		GlobalNodes.nodes.get_node_instance(ids[i]).node_state = froms[i]
	GlobalNodes.inspector.node_inspector.update_state_button()

func redo():
	for id in ids:
		GlobalNodes.nodes.get_node_instance(id).node_state = to
	GlobalNodes.inspector.node_inspector.update_state_button()

func _init(_ids : Array[int], _froms : Array[Constants.NodeState], _to : Constants.NodeState) -> void:
	name = "Node State Modify"
	ids = _ids
	froms = _froms
	to = _to
