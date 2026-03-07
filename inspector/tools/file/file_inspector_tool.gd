class_name FileInspectorTool
extends BaseInspectorTool

@export var button_node : Button
@export var file_dialog: FileDialog

func setup():
	file_dialog.filters = property.filters

func _on_button_pressed() -> void:
	file_dialog.popup_centered()

func _on_file_selected(selected_path: String) -> void:
	set_value(selected_path)

func update_value(value : Variant):
	button_node.text = property.value.get_file() if property.value else "..."
