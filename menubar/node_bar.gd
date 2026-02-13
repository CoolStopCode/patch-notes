extends HBoxContainer

@export var node_type_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node_type in Constants.NODE_LIST.node_list:
		var node := node_type_scene.instantiate()
		node.mini_icon = node_type.mini_icon
		node.name = node_type.name
		node.node_scene = node_type.node_scene
		add_child(node)
