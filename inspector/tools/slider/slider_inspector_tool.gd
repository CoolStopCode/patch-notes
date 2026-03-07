class_name SliderInspectorTool
extends BaseInspectorTool

@export var line_edit_node : LineEdit
@export var slider_node : Slider
var temp_value : float

func update_value(value : Variant):
	_update_slider_state()
	line_edit_node.text = str(value)

func setup():
	slider_node.step = property.step_slider
	slider_node.min_value = property.value
	slider_node.max_value = property.value
	slider_node.value = property.value
	slider_node.min_value = property.min_slider
	slider_node.max_value = property.max_slider

func _on_text_changed(new_text: String) -> void:
	if new_text == "":
		return

	var filtered := ""
	for c in new_text:
		if (c >= "0" and c <= "9") or c == "-":
			filtered += c

	if filtered != new_text:
		var caret := line_edit_node.caret_column
		set_value(float(filtered))
		line_edit_node.caret_column = min(caret, filtered.length())

func _on_text_submitted(new_text: String) -> void:
	if line_edit_node.text == "":
		set_value(property.min_value)
	else:
		set_value(clamp(float(line_edit_node.text), property.min_value, property.max_value))

func _update_slider_state():
	slider_node.set_block_signals(true)
	slider_node.value = clamp(property.value, property.min_slider, property.max_slider)
	slider_node.set_block_signals(false)

func _on_slider_value_changed(new_value: float) -> void:
	temp_value = new_value
	line_edit_node.text = str(temp_value)

func _on_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		set_value(temp_value)
