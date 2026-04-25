extends Node

var pinned_nodes: Array[String] = []
var extension_data_list : Array[Dictionary] = []

class ExtensionData:
	var path : String
	var root_name : String
	
	func _init(_path : String, _root_name : String) -> void:
		path = _path
		root_name = _root_name
	
	func to_dict() -> Dictionary:
		return {
			"path": path,
			"root_name": root_name
		}
	
	static func from_dict(d: Dictionary) -> ExtensionData:
		return ExtensionData.new(d.get("path", ""), d.get("root_name", ""))

func is_pinned(node: NodeType) -> bool:
	var node_path = node.node_scene.resource_path
	return pinned_nodes.has(node_path)

func set_pinned(node : NodeType, pinned: bool) -> void:
	if pinned:
		if not is_pinned(node):
			pinned_nodes.append(node.node_scene.resource_path)
	else:
		pinned_nodes.erase(node.node_scene.resource_path)
	save_config()

func toggle_pinned(node : NodeType) -> void:
	set_pinned(node, not is_pinned(node))

func add_default_pins(extension_list : Extension):
	for node_type in extension_list.node_list:
		set_pinned(node_type, node_type.default_pinned)

func new_extension_data(path : String, root_name : String):
	extension_data_list.append(ExtensionData.new(path, root_name).to_dict())
	save_config()

# --- Persistence ---

func save_config() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("pins", "pinned_nodes", pinned_nodes)
	cfg.set_value("extensions", "extension_data_list", extension_data_list)
	cfg.save(FileManager.BASE_PATH.path_join("config.cfg"))

func load_config() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(FileManager.BASE_PATH.path_join("config.cfg")) != OK:
		return
	pinned_nodes = cfg.get_value("pins", "pinned_nodes", [])
	extension_data_list = cfg.get_value("extensions", "extension_data_list", [])
