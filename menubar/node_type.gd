extends Button

@export var mini_icon : Texture
@export var node_name : String
@export var node_scene : PackedScene

@export var texture : TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tooltip_text = node_name
	texture.texture = mini_icon


func _on_pressed() -> void:
	if Cursor.dragging: return
	var node := node_scene.instantiate()
	var base_node := node.get_child(0)
	base_node.mouse_dragging = true
	base_node.drag_offset = Vector2(0, 0)
	base_node.distance_moved = Vector2(10, 10)
	Cursor.dragging = true
	GlobalNodes.nodes.add_child(node)
