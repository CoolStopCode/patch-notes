extends Node

var pinned_nodes: Array[NodeType] = []

func is_pinned(node: NodeType) -> bool:
	return pinned_nodes.has(node)

func set_pinned(node : NodeType, pinned: bool) -> void:
	if pinned:
		if not pinned_nodes.has(node):
			print("PINNING NODE ", node.name)
			pinned_nodes.append(node)
	else:
		pinned_nodes.erase(node)
	save_config()

func toggle_pinned(node : NodeType) -> void:
	set_pinned(node, not is_pinned(node))

func add_default_pins(extension_list : Extension):
	for node_type in extension_list.node_list:
		set_pinned(node_type, node_type.default_pinned)

# --- Persistence ---

func save_config() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("pins", "pinned_nodes", pinned_nodes)
	cfg.save(FileManager.BASE_PATH.path_join("config.cfg"))

func load_config() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(FileManager.BASE_PATH.path_join("config.cfg")) != OK:
		return
	pinned_nodes = cfg.get_value("pins", "pinned_nodes", [])
