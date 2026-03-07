class_name HistoryPropertyModify
extends HistoryAction

var node_id : int
var from : Array[InspectorProperty]
var to : Array[InspectorProperty]


func undo():
	var node = GlobalNodes.nodes.get_node_instance(node_id)
	node.properties = from.duplicate(true)
	#gojif'fsdfidojg'iofdgjsd'gjs'ifgjsiodf
	GlobalNodes.inspector.open_node_inspector(node)

func redo():
	var node = GlobalNodes.nodes.get_node_instance(node_id)
	node.properties = to.duplicate(true)
	GlobalNodes.inspector.open_node_inspector(node)

func _init(_node_id: int, _from: Array, _to: Array) -> void:
	node_id = _node_id
	from = _from
	to = _to
