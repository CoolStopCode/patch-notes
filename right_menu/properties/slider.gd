extends Control

@export var property_name: String
@export var value: float
@export var min_value: float = 0.0
@export var max_value: float = 100.0
@export var min_slider: float = 0.0
@export var max_slider: float = 10.0
@export var step_slider: float = 0.1

@export var line_edit_node : LineEdit
@export var slider_node : Slider
@export var name_node : Label

var property: RightMenuProperty 
var node: Node

func bind_to_property(prop: RightMenuProperty, target_node: Node) -> void:
	property = prop
	node = target_node

	property_name = property.property_name
	
	value = property.value
	min_value = property.min_value
	max_value = property.max_value
	min_slider = property.min_slider
	max_slider = property.max_slider
	step_slider = property.step_slider
	
	_load_exports()
	
	_update_slider_state()

func _load_exports():
	
	name_node.text = property_name
	line_edit_node.text = str(value)
	
	slider_node.step = step_slider
	slider_node.min_value = value
	slider_node.max_value = value # ensure no clamping happens before min and max are set
	slider_node.value = value
	print(value)
	slider_node.min_value = min_slider
	slider_node.max_value = max_slider
	print(value)
	

func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text == "":
		return

	var filtered := ""
	for c in new_text:
		if (c >= "0" and c <= "9") or c == "-" or c == ".":
			filtered += c

	if filtered != new_text:
		var caret := line_edit_node.caret_column
		line_edit_node.text = filtered
		line_edit_node.caret_column = min(caret, filtered.length())
	
	property_changed()
	_update_slider_state()

func _commit_text():
	var text := line_edit_node.text
	if text == "":
		value = min_value
	else:
		value = clamp(float(text), min_value, max_value)
	line_edit_node.text = str(value)
	property_changed()
	_update_slider_state()

func _update_slider_state():
	slider_node.set_block_signals(true)
	slider_node.value = clamp(value, min_slider, max_slider)
	slider_node.set_block_signals(false)


func _on_line_edit_focus_exited() -> void:
	_commit_text()

func _on_line_edit_text_submitted(_new_text: String) -> void:
	_commit_text()


func _on_slider_value_changed(new_value: float) -> void:
	if new_value < min_slider or new_value > max_slider:
		return
	value = new_value
	property_changed()
	line_edit_node.text = str(value)

func property_changed():
	property.value = value
	node.property_changed(property)
