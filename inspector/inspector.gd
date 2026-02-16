extends Control

@export var properties_container: VBoxContainer
@export var state_button : Button
@export var icon_node : TextureRect

var property_scenes: Dictionary = {
	RightMenuArrows: preload("res://inspector/properties/arrows.tscn"),
	RightMenuBool: preload("res://inspector/properties/checkbox.tscn"),
	RightMenuFile: preload("res://inspector/properties/file.tscn"),
	RightMenuSlider: preload("res://inspector/properties/slider.tscn")
}

var active_node : Node
var active := false

func _ready() -> void:
	active = false
	hide()
	GlobalNodes.inspector = self

func initialize(node : Node2D):
	Constants.clear_children(properties_container)
	active_node = node
	for property: RightMenuProperty in node.properties:
		var script: Script = property.get_script()
		var ui : Control = property_scenes[script].instantiate()
		properties_container.add_child(ui)
		ui.bind_to_property(property, node)
	
	state_button.load_state(node.base_node.node_state)
	icon_node.texture = node.base_node.right_menu_icon
	active = true
	show()

func close():
	active = false
	hide()
	
	Constants.clear_children(properties_container)

func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventMouseButton and event.pressed:
		var pos := get_global_mouse_position()
		if not get_global_rect().has_point(pos):
			close()

func _on_delete_pressed() -> void:
	if active:
		active_node.base_node.parent.queue_free()
		close()

func _on_duplicate_pressed() -> void:
	if active:
		var copy = active_node.base_node.parent.duplicate()
		copy.global_position += Constants.snap_to_grid(Vector2(5, 5))
		GlobalNodes.nodes.add_child(copy)
		close()

func _on_state_set(state: Constants.NodeState) -> void:
	if active:
		active_node.base_node.node_state = state
