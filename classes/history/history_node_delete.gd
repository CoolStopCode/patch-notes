class_name HistoryNodeDelete
extends HistoryAction

var node_scene : PackedScene
var id : int
var position : Vector2
var properties : Array[InspectorProperty]

func undo():
	var node = node_scene.instantiate()
	node.creation_drag = false
	node.duplicate_props = false
	node.position = position
	node.properties = properties
	GlobalNodes.nodes.add_child(node)
	GlobalNodes.nodes.nodes[id] = node

func redo():
	var node : Node = GlobalNodes.nodes.get_node_instance(id)
	node.queue_free()
	if GlobalNodes.inspector.node_inspector.active_node == node:
		GlobalNodes.inspector.node_inspector.close()

func _init(_node_scene, _id, _position, _properties) -> void:
	node_scene = _node_scene
	id = _id
	position = _position
	properties = _properties
