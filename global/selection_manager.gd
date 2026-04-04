extends Node

enum CursorState {
	NORMAL,
	HOVER,
	DRAG
}

signal selection_changed(nodes: Array[BaseNode])
var selected_nodes: Array[BaseNode] = []
var dragged_nodes: Array[BaseNode] = []
var hovered_nodes: Array[BaseNode] = []

func start_hover(node: BaseNode):
	if node not in hovered_nodes:
		hovered_nodes.append(node)
	for n in hovered_nodes:
		n.hover_ended()
	node.hover_started()
	update_cursor_state()

func end_hover(node: BaseNode):
	if node in hovered_nodes:
		hovered_nodes.erase(node)
	
	node.hover_ended()
	if hovered_nodes.size() > 0:
		var max_node : BaseNode = hovered_nodes[0]
		for n in hovered_nodes:
			if n.ID > max_node.ID:
				max_node = n
		if max_node:
			max_node.hover_started()
	update_cursor_state()

func start_drag(node: BaseNode):
	if node not in dragged_nodes:
		dragged_nodes.append(node)
	node.drag_started()
	update_cursor_state()

func end_drag():
	for node in dragged_nodes:
		node.drag_ended()
		dragged_nodes.erase(node)
	update_cursor_state()

func select(node: BaseNode, additive := false):
	if not additive:
		deselect_all()
	if node not in selected_nodes:
		selected_nodes.append(node)
		node.selected()
		selection_changed.emit(selected_nodes)
	update_inspector()

func deselect(node: BaseNode):
	if node in selected_nodes:
		selected_nodes.erase(node)
		node.deselected()
	
	update_inspector()
	selection_changed.emit(selected_nodes)

func deselect_all():
	for n in selected_nodes:
		n.deselected()
	selected_nodes.clear()
	
	update_inspector()
	selection_changed.emit(selected_nodes)

func select_multiple(nodes: Array[BaseNode]):
	deselect_all()
	for n in nodes:
		selected_nodes.append(n)
		n.selected()
	
	update_inspector()
	selection_changed.emit(selected_nodes)

func move_all_selected(delta: Vector2):
	for n in selected_nodes:
		n.global_position = Constants.snap_to_grid(n.global_position + delta)
		n.move.emit()

func update_inspector():
	if selected_nodes.is_empty():
		GlobalNodes.inspector.close_node_inspector()
	else:
		GlobalNodes.inspector.open_node_inspector()

func update_cursor_state():
	if not dragged_nodes.is_empty():
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)
	elif not hovered_nodes.is_empty():
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
