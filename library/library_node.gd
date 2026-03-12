extends Control


signal node_used(node : NodeType)
var node : NodeType
@export var icon : TextureRect
@export var text : Label

func _on_use_pressed() -> void:
	node_used.emit(node)
