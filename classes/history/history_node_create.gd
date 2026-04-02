class_name HistoryNodeCreate
extends HistoryAction

var node_scenes : Array[PackedScene]
var ids : Array[int]
var positions : Array[Vector2]
var properties : Array[Array]

func undo():
	for id in ids:
		var node : Node = GlobalNodes.nodes.get_node_instance(id)
		node.queue_free()
		if node in SelectionManager.selected_nodes:
			SelectionManager.deselect(node)

func redo():
	for i in range(ids.size()):
		var node = node_scenes[i].instantiate()
		node.creation_drag = false
		node.duplicate_props = false
		node.position = positions[i]
		node.properties = properties[i]
		node.ID = ids[i]
		GlobalNodes.nodes.add_child(node)
		GlobalNodes.nodes.nodes[ids[i]] = node

func _init(
	_node_scenes : Array[PackedScene],
	_ids : Array[int],
	_positions : Array[Vector2],
	_properties : Array[Array]
) -> void:
	name = "Node Create"
	node_scenes = _node_scenes
	ids = _ids
	positions = _positions
	properties = _properties
