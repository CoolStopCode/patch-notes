extends Control

@export var property_name: String
@export var extensions: PackedStringArray = [] # ["wav", "ogg"]
@export_file var path: String

@export var name_node : Label
@export var button_node : Button
@export var file_dialog: FileDialog

func load_exports():
	name_node.text = property_name
	
	var filters := []
	for ext in extensions:
		filters.append("*." + ext)
	file_dialog.filters = filters

func _on_button_pressed() -> void:
	# Show the file dialog
	file_dialog.popup_centered()


func _on_file_selected(selected_path: String) -> void:
	path = selected_path
	var file_name = selected_path.get_file()  # <-- only the file name
	print("Loaded file: ", file_name)
	button_node.text = file_name
