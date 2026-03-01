class_name HistoryNodeCreate
extends HistoryAction

var node_scene : PackedScene
var id : int
var position : Vector2

func undo():
	GlobalNodes.nodes.get_node_instance(id).queue_free()

func redo():
	var node = node_scene.instantiate()
	node.position = position
	GlobalNodes.nodes.add_child(node)
	GlobalNodes.nodes.nodes[id] = node

func _init(_node_scene, _id, _position) -> void:
	node_scene = _node_scene
	id = _id
	position = _position
