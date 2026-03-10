extends Control

@export var properties_container: VBoxContainer
@export var state_button : Button
@export var icon_node : TextureRect

var property_scenes: Dictionary = {
	InspectorCheckbox: preload("res://inspector/tools/checkbox/checkbox_inspector_tool.tscn"),
	InspectorFile: preload("res://inspector/tools/file/file_inspector_tool.tscn"),
	InspectorArrows: preload("res://inspector/tools/arrows/arrows_inspector_tool.tscn"),
	InspectorSlider: preload("res://inspector/tools/slider/slider_inspector_tool.tscn")
}

var active_node : Node
var active := false

func open(node : Node2D):
	active_node = node
	active_node.selected()
	show()
	Constants.clear_children(properties_container)
	for property: InspectorProperty in node.properties:
		var script: Script = property.get_script()
		var ui : Control = property_scenes[script].instantiate()
		properties_container.add_child(ui)
		ui.initiate(property, node)
	
	state_button.load_state(node.node_state)
	if node.right_menu_icon:
		icon_node.texture = node.right_menu_icon
	active = true

func close():
	if not active: return
	active_node.deselected()
	hide()
	active = false
	Constants.clear_children(properties_container)

func _input(event: InputEvent) -> void:
	if not active: return

	if event is InputEventMouseButton and event.pressed:
		var pos := get_global_mouse_position()
		if not get_global_rect().has_point(pos):
			close()

func _on_delete_pressed() -> void:
	if active:
		History.commit(HistoryNodeDelete.new(
			load(active_node.scene_file_path), 
			active_node.ID, 
			active_node.global_position, 
			active_node.properties
		))
		active_node.queue_free()
		close()

func _on_duplicate_pressed() -> void:
	if active:
		var node_scene := load(active_node.scene_file_path)
		var copy : Node = node_scene.instantiate()
		copy.properties = active_node.properties
		copy.global_position = active_node.global_position + Constants.snap_to_grid(Vector2(5, 5))
		copy.creation_drag = false
		copy.duplicate_props = true
		GlobalNodes.nodes.add_node(copy)
		History.commit(HistoryNodeCreate.new(
			node_scene, 
			copy.ID,
			copy.global_position, 
			copy.properties
		))
		close()
		open(copy)

func _on_state_set(state: Constants.NodeState) -> void:
	if active:
		var from : Constants.NodeState = active_node.node_state
		active_node.node_state = state
		History.commit(HistoryNodeStateModify.new(active_node.ID, from, state))

func update_state_button():
	if active:
		state_button.apply_state(active_node.node_state)
