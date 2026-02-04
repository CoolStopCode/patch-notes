class_name RightMenuArrows
extends RightMenuProperty

@export var value: int
@export var min_value: int = 0
@export var max_value: int = 100
@export var step: int = 1


func apply_to(ui: Node) -> void:
	super.apply_to(ui)
	ui.value = value
	ui.min_value = min_value
	ui.max_value = max_value
	ui.step = step
