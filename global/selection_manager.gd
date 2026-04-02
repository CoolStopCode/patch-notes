extends Node

signal selection_changed(nodes: Array[BaseNode])
var selected_nodes: Array[BaseNode] = []
var hovered_nodes: Array[BaseNode] = []

func start_hover(node: BaseNode):
	if node not in hovered_nodes:
		hovered_nodes.append(node)
	for n in hovered_nodes:
		n.hover_ended()
	node.hover_started()

func end_hover(node: BaseNode):
	if node in hovered_nodes:
		hovered_nodes.erase(node)
	
	node.hover_ended()
	if hovered_nodes.size() > 0:
		hovered_nodes[0].hover_started()

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
