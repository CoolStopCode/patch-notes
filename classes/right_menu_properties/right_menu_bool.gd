class_name RightMenuBool
extends RightMenuProperty

@export var value: bool

func apply_to(ui: Node) -> void:
	super.apply_to(ui)
	ui.value = value
