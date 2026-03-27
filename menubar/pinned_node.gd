extends Button

@export var node_icon : Texture
@export var node_name : String
@export var node_scene : PackedScene

@export var texture : TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tooltip_text = node_name
	texture.texture = node_icon


func _on_pressed() -> void:
	if Cursor.dragging: return
	var node := node_scene.instantiate()
	node.creation_drag = true
	node.duplicate_props = true
	node.drag_offset = Vector2(0, 0)
	Cursor.dragging = true
	GlobalNodes.nodes.add_node(node)
