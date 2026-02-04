class_name RightMenuFile
extends RightMenuProperty

@export var extensions: PackedStringArray = [] # ["wav", "ogg"]
@export_file var path: String

func apply_to(ui: Node) -> void:
	super.apply_to(ui)
	ui.extensions = extensions
	ui.path = path
