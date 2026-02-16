extends Control

@export var property_name: String
@export var extensions: PackedStringArray = [] # ["wav", "ogg"]
@export_file var path: String

@export var name_node : Label
@export var button_node : Button
@export var file_dialog: FileDialog

var property: RightMenuProperty 
var node: Node

func bind_to_property(prop: RightMenuProperty, target_node: Node) -> void:
	property = prop
	node = target_node

	property_name = property.property_name
	extensions = property.extensions
	path = property.path
	
	
	_load_exports()

func _load_exports():
	name_node.text = property_name
	button_node.text = path.get_file() if path else "Load"
	
	var filters := []
	for ext in extensions:
		filters.append("*." + ext)
	file_dialog.filters = filters

func _on_button_pressed() -> void:
	file_dialog.popup_centered()


func _on_file_selected(selected_path: String) -> void:
	path = selected_path
	var file_name = selected_path.get_file()
	property_changed()
	button_node.text = file_name

func property_changed():
	property.path = path
	node.property_changed(property)
