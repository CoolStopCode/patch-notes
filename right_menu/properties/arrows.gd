extends Control

@export var property_name: String
@export var value: int
@export var min_value: int = 0
@export var max_value: int = 100
@export var step: int = 1

@export var line_edit_node : LineEdit
@export var left_button : BaseButton
@export var right_button : BaseButton
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
	step = property.step
	
	_load_exports()

func _load_exports():
	name_node.text = property_name
	line_edit_node.text = str(value)

func _ready() -> void:
	_update_button_state()

func _on_left_pressed() -> void:
	value -= step
	line_edit_node.text = str(value)
	property_changed()
	_update_button_state()


func _on_right_pressed() -> void:
	value += step
	line_edit_node.text = str(value)
	property_changed()
	_update_button_state()


func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text == "":
		return

	var filtered := ""
	for c in new_text:
		if (c >= "0" and c <= "9") or c == "-":
			filtered += c

	if filtered != new_text:
		var caret := line_edit_node.caret_column
		line_edit_node.text = filtered
		line_edit_node.caret_column = min(caret, filtered.length())
	
	property_changed()
	_update_button_state()

func _commit_text():
	var text := line_edit_node.text
	if text == "":
		value = min_value
	else:
		value = clampi(int(text), min_value, max_value)
	line_edit_node.text = str(value)
	property_changed()
	_update_button_state()

func _update_button_state():
	right_button.disabled = value + step > max_value
	left_button.disabled = value - step < min_value


func _on_line_edit_focus_exited() -> void:
	_commit_text()

func _on_line_edit_text_submitted(_new_text: String) -> void:
	_commit_text()

func property_changed():
	property.value = value
	node.property_changed(property)
