extends Control


signal node_used(node : NodeType)
signal node_pin_update(node : NodeType, pinned : bool)

var node : NodeType

@export var icon : TextureRect
@export var text : Label
@export var pinned : bool

@export var pin_texture_node : TextureRect
@export var pin_texture_enabled : Texture
@export var pin_texture_disabled : Texture

func _ready() -> void:
	update_texture()

func _on_use_pressed() -> void:
	node_used.emit(node)

func _on_pin_pressed() -> void:
	pinned = not pinned
	node_pin_update.emit(node, pinned)
	update_texture()

func update_texture():
	pin_texture_node.texture = pin_texture_enabled if pinned else pin_texture_disabled
