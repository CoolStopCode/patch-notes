class_name HistoryNodeCreate
extends HistoryAction

var node_scene : PackedScene
var node : Node2D
var position : Vector2

func undo():
	# node.queue_free()
	node.hide()

func redo():
	#node = node_scene.instantiate()
	#node.position = position
	#GlobalNodes.nodes.add_child(node)
	node.show()

func _init(_node_scene, _node, _position) -> void:
	node_scene = _node_scene
	node = _node
	position = _position
