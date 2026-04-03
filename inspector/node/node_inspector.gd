extends Control

@export var properties_container: VBoxContainer
@export var state_button : Button
@export var icon_node : TextureRect
@export var missing_key : Texture
@export var multi_key : Texture

var property_scenes: Dictionary = {
	InspectorCheckbox: preload("res://inspector/tools/checkbox/checkbox_inspector_tool.tscn"),
	InspectorFile: preload("res://inspector/tools/file/file_inspector_tool.tscn"),
	InspectorArrows: preload("res://inspector/tools/arrows/arrows_inspector_tool.tscn"),
	InspectorSlider: preload("res://inspector/tools/slider/slider_inspector_tool.tscn"),
	InspectorNote: preload("res://inspector/tools/note/note_inspector_tool.tscn")
}

var active_node : Node
var active := false

func are_nodes_same():
	var first := SelectionManager.selected_nodes[0].NODE_SCENE
	for n in SelectionManager.selected_nodes:
		if n.NODE_SCENE != first:
			return false
	return true

func are_states_same():
	var first := SelectionManager.selected_nodes[0].node_state
	for n in SelectionManager.selected_nodes:
		if n.node_state != first:
			return false
	return true

func open() -> void:
	show()
	Constants.clear_children(properties_container)
	
	var primary_node := SelectionManager.selected_nodes[0]
	
	if are_nodes_same():
		for i in primary_node.properties.size():
			var script: Script = primary_node.properties[i].get_script()
			var ui: Control = property_scenes[script].instantiate()
			properties_container.add_child(ui)
			
			var properties_at_index: Array[InspectorProperty] = []
			for n in SelectionManager.selected_nodes:
				properties_at_index.append(n.properties[i])
			ui.initiate(properties_at_index)
		if primary_node.right_menu_icon:
			icon_node.texture = primary_node.right_menu_icon
		else:
			icon_node.texture = missing_key
	else:
		icon_node.texture = multi_key
	
	active = true
	update_state_button()

func update():
	Constants.clear_children(properties_container)
	
	var primary_node := SelectionManager.selected_nodes[0]
	
	if are_nodes_same():
		for i in primary_node.properties.size():
			var script: Script = primary_node.properties[i].get_script()
			var ui: Control = property_scenes[script].instantiate()
			properties_container.add_child(ui)
			
			var properties_at_index: Array[InspectorProperty] = []
			for n in SelectionManager.selected_nodes:
				properties_at_index.append(n.properties[i])
			ui.initiate(properties_at_index)
		if primary_node.right_menu_icon:
			icon_node.texture = primary_node.right_menu_icon
		else:
			icon_node.texture = missing_key
	else:
		icon_node.texture = multi_key
	
	active = true
	update_state_button()

func close():
	if not active: return
	hide()
	active = false
	Constants.clear_children(properties_container)

func _input(event: InputEvent) -> void:
	if not active: return

	if event is InputEventMouseButton and event.pressed:
		var pos := get_global_mouse_position()
		if not get_global_rect().has_point(pos):
			if SelectionManager.hovered_nodes.is_empty():
				SelectionManager.deselect_all()

func _on_delete_pressed() -> void:
	if active:
		delete_node()

func _on_duplicate_pressed() -> void:
	if active:
		duplicate_node()

func duplicate_node():
	var new_selected : Array[BaseNode]
	
	var node_scenes : Array[PackedScene]
	var ids : Array[int]
	var positions : Array[Vector2]
	var properties : Array[Array]
	for node in SelectionManager.selected_nodes:
		var node_scene := load(node.scene_file_path)
		var copy : Node = node_scene.instantiate()

		copy.properties = node.properties
		copy.duplicate_props = true

		copy.global_position = node.global_position + Constants.snap_to_grid(Vector2(5, 5))
		copy.creation_drag = false

		GlobalNodes.nodes.add_node(copy)
		new_selected.append(copy)
		
		node_scenes.append(node_scene)
		ids.append(copy.ID)
		positions.append(copy.global_position)
		properties.append(copy.properties)

	History.commit(HistoryNodeCreate.new(
		node_scenes,
		ids,
		positions,
		properties
	))
	SelectionManager.select_multiple(new_selected)

func delete_node():
	var node_scenes: Array[PackedScene]
	var ids: Array[int]
	var positions: Array[Vector2]
	var properties: Array[Array]
	
	var temp_selected_nodes : Array[BaseNode] = SelectionManager.selected_nodes.duplicate(false)
	
	for node in temp_selected_nodes:
		node_scenes.append(load(node.scene_file_path))
		ids.append(node.ID)
		positions.append(node.global_position)
		properties.append(node.properties)
		SelectionManager.deselect(node)
		SelectionManager.end_hover(node)
		node.queue_free()
	History.commit(HistoryNodeDelete.new(
		node_scenes, 
		ids,
		positions,
		properties
	))
	close()

func _on_state_set(state: Constants.NodeState) -> void:
	if not active: return
	
	var ids : Array[int]
	var froms : Array[Constants.NodeState]
	for node in SelectionManager.selected_nodes:
		ids.append(node.ID)
		froms.append(node.node_state)
		node.node_state = state
	History.commit(HistoryNodeStateModify.new(ids, froms, state))

func update_state_button():
	if not active: return
	var primary_node := SelectionManager.selected_nodes[0]
	
	if are_states_same():
		state_button.load_state(primary_node.node_state)
	else:
		state_button.load_state(Constants.NodeState.NULL)

func _unhandled_input(event):
	if not active: return

	if event.is_action_pressed("duplicate"):
		duplicate_node()
	
	if event.is_action_pressed("delete"):
		delete_node()
