extends HBoxContainer

@export var node_type_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node_list in Constants.PACK_LIST.pack_list:
		for node_type in node_list.node_list:
			var node := node_type_scene.instantiate()
			node.node_icon = node_type.icon
			node.name = node_type.name
			node.node_scene = node_type.node_scene
			add_child(node)
	


func _on_library_pressed() -> void:
	GlobalNodes.library.open()
