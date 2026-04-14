extends HBoxContainer

@export var node_type_scene : PackedScene
@export var library_button_node : Button

func _ready() -> void:
	GlobalNodes.node_bar = self
	refresh()

func refresh():
	for n in get_children():
		if n == library_button_node:
			continue
		remove_child(n)
		n.queue_free()
	for node_list in FileManager.EXTENSION_LIST.extension_list:
		for node_type in node_list.node_list:
			if node_type.pinned:
				var node := node_type_scene.instantiate()
				node.node_icon = node_type.icon
				node.name = node_type.name
				node.node_scene = node_type.node_scene
				add_child(node)


func _on_library_pressed() -> void:
	GlobalNodes.library.open()
