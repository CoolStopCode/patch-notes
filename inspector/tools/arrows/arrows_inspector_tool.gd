class_name ArrowsInspectorTool
extends BaseInspectorTool

@export var line_edit_node : LineEdit
@export var left_button : BaseButton
@export var left_texture_rect: TextureRect
@export var right_button : BaseButton
@export var right_texture_rect: TextureRect

@export var left_texture_enabled: Texture
@export var left_texture_disabled: Texture
@export var right_texture_enabled: Texture
@export var right_texture_disabled: Texture

func update_value(value : Variant):
	line_edit_node.text = str(value)
	_update_button_state()


func _on_left_pressed() -> void:
	set_value(property.value - 1)


func _on_right_pressed() -> void:
	set_value(property.value + 1)


func _on_text_changed(new_text: String) -> void:
	if new_text == "":
		return

	var filtered := ""
	for c in new_text:
		if (c >= "0" and c <= "9") or c == "-":
			filtered += c

	if filtered != new_text:
		var caret := line_edit_node.caret_column
		set_value(int(filtered))
		line_edit_node.caret_column = min(caret, filtered.length())

func _on_text_submitted(new_text: String) -> void:
	if line_edit_node.text == "":
		set_value(property.min_value)
	else:
		set_value(clampi(int(line_edit_node.text), property.min_value, property.max_value))

func _update_button_state():
	if property.value + property.step > property.max_value:
		right_button.disabled = true
		right_texture_rect.texture = right_texture_disabled
	else:
		right_button.disabled = false
		right_texture_rect.texture = right_texture_enabled
	
	if property.value - property.step < property.min_value:
		left_button.disabled = true
		left_texture_rect.texture = left_texture_disabled
	else:
		left_button.disabled = false
		left_texture_rect.texture = left_texture_enabled
