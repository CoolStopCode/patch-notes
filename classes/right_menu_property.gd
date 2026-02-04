class_name RightMenuProperty
extends Resource

@export var property_name: String

func apply_to(ui: Node) -> void:
	ui.property_name = property_name
