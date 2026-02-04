class_name RightMenuSlider
extends RightMenuProperty

@export var value: float
@export var min_value: float = 0.0
@export var max_value: float = 100.0
@export var min_slider: float = 0.0
@export var max_slider: float = 10.0
@export var step_slider: float = 0.1


func apply_to(ui: Node) -> void:
	super.apply_to(ui)
	ui.value = value
	ui.min_value = min_value
	ui.max_value = max_value
	ui.min_slider = min_slider
	ui.max_slider = max_slider
	ui.step_slider = step_slider
