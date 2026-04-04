class_name HistoryNodeDelete
extends HistoryAction

class NodeSnapshot:
	var node_scene: PackedScene
	var id: int
	var position: Vector2
	var properties: Array[InspectorProperty]

class ConnectionSnapshot:
	var id: int
	var from_id: int
	var from_port: int
	var to_id: int
	var to_port: int
	var color: Color
	var points: PackedVector2Array
	var state: Constants.ConnectionState

var node_snapshots: Array[NodeSnapshot] = []
var connection_snapshots: Array[ConnectionSnapshot] = []

func undo() -> void:
	for snap in node_snapshots:
		var node = snap.node_scene.instantiate()
		node.creation_drag = false
		node.duplicate_props = false
		node.position = snap.position
		node.properties = snap.properties
		node.ID = snap.id
		GlobalNodes.nodes.add_child(node)
		GlobalNodes.nodes.nodes[snap.id] = node

	for snap in connection_snapshots:
		var line : Node2D = GlobalNodes.connections.quick_create_line(snap.points, snap.color)
		GlobalNodes.connections.add_child(line)

		var connection := Connection.new(
			GlobalNodes.nodes.get_node_instance(snap.from_id),
			snap.from_port,
			GlobalNodes.nodes.get_node_instance(snap.to_id),
			snap.to_port,
			line
		)
		connection.ID = snap.id
		connection.set_line_color(snap.color)
		connection.connection_state = snap.state
		GlobalNodes.connections.connections[snap.id] = connection

func redo() -> void:
	for snap in node_snapshots:
		var node : BaseNode = GlobalNodes.nodes.get_node_instance(snap.id)
		if GlobalNodes.inspector.node_inspector.active_node == node:
			GlobalNodes.inspector.node_inspector.close()
		node.queue_free()

func _init(
	_node_scenes: Array[PackedScene],
	_ids: Array[int],
	_positions: Array[Vector2],
	_properties: Array[Array]
) -> void:
	name = "Node Delete"

	var deleted_ids := {}
	for i in _ids.size():
		var snap := NodeSnapshot.new()
		snap.node_scene = _node_scenes[i]
		snap.id = _ids[i]
		snap.position = _positions[i]
		snap.properties = _properties[i]
		node_snapshots.append(snap)
		deleted_ids[_ids[i]] = true

	var seen_connection_ids := {}
	for connection in GlobalNodes.connections.connections:
		if connection.freed: continue
		if not (connection.from.ID in deleted_ids or connection.to.ID in deleted_ids):
			continue
		if connection.ID in seen_connection_ids:
			continue
		seen_connection_ids[connection.ID] = true

		var snap := ConnectionSnapshot.new()
		snap.id = connection.ID
		snap.from_id = connection.from.ID
		snap.from_port = connection.from_port
		snap.to_id = connection.to.ID
		snap.to_port = connection.to_port
		snap.color = connection.color
		snap.points = connection.line.line.points
		snap.state = connection.connection_state
		connection_snapshots.append(snap)
