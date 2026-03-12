extends Control

var active := false
var categories := true

@export var nodes_page : Control
@export var categories_page : Control
@export var category_scene : PackedScene
@export var node_scene : PackedScene

@export var exit_button : Button
func _ready() -> void:
	GlobalNodes.library = self

func open():
	active = true
	load_categories()
	show()

func close():
	active = false
	hide()

func _input(event: InputEvent) -> void:
	if not active: return

	if event is InputEventMouseButton and event.pressed:
		var pos := get_global_mouse_position()
		if not get_global_rect().has_point(pos):
			close()

func load_categories():
	categories = true
	categories_page.show()
	Constants.clear_children(categories_page)
	nodes_page.hide()
	Constants.clear_children(nodes_page)
	exit_button.hide()
	for category : NodeList in Constants.PACK_LIST.pack_list:
		var instance := category_scene.instantiate()
		instance.icon.texture = category.icon
		instance.text.text = category.name
		instance.category = category
		instance.category_opened.connect(load_nodes)
		categories_page.add_child(instance)

func load_nodes(node_list : NodeList):
	categories = false
	categories_page.hide()
	Constants.clear_children(categories_page)
	nodes_page.show()
	exit_button.show()
	Constants.clear_children(nodes_page)
	for node : NodeType in node_list.node_list:
		var instance := node_scene.instantiate()
		instance.icon.texture = node.icon
		instance.text.text = node.name
		instance.node = node
		instance.node_used.connect(node_used)
		nodes_page.add_child(instance)

func node_used(node : NodeType):
	pass


func _on_exit_pressed() -> void:
	load_categories()
