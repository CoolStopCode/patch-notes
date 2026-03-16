class_name BPMInspectorTool
extends BaseInspectorTool


@export var checkbox_texture_rect : TextureRect
@export var off_texture : Texture
@export var on_texture : Texture

@export var local_min_value: float = 10.0
@export var local_max_value: float = 50000.0
@export var local_min_slider: float = 60.0
@export var local_max_slider: float = 200.0
@export var local_step_slider: float = 1.0

@export var global_min_bpm: float = 10.0
@export var global_max_bpm: float = 10000.0
@export var global_min_mult: int = 1
@export var global_max_mult: int = 128

var temp_value : float

@export_category("global")
@export var global_parent : Control
@export var global_bpm_edit_node : LineEdit
@export var global_mult_edit_node : LineEdit

@export_category("local")
@export var local_parent : Control
@export var local_bpm_edit_node : LineEdit
@export var local_slider_node : Slider

func update_value(value : Variant):
	_update_local_slider_state()
	update_checkbox_textures()
	local_bpm_edit_node.text = str(value[1])
	global_bpm_edit_node.text = str(Constants.global_bpm)
	global_mult_edit_node.text = str(value[2])
	local_parent.visible = not value[0]
	global_parent.visible = value[0]

# CHECKBOX ===================================================
func _on_checkbox_pressed() -> void:
	set_value([not property.value[0], property.value[1], property.value[2]])

func update_checkbox_textures():
	if property.value[0]:
		checkbox_texture_rect.texture = on_texture 
	else:
		checkbox_texture_rect.texture = off_texture 

# LOCAL ====================================================
func _on_local_text_changed(new_text: String) -> void:
	if new_text == "":
		return

	var filtered := ""
	for c in new_text:
		if (c >= "0" and c <= "9") or c == "-" or c == ".":
			filtered += c

	if filtered != new_text:
		var caret := local_bpm_edit_node.caret_column - 1
		set_value([false, float(filtered), property.value[2]])
		local_bpm_edit_node.caret_column = min(caret, filtered.length())

func _on_local_text_submitted(new_text: String) -> void:
	if local_bpm_edit_node.text == "":
		set_value([false, local_min_value, property.value[2]])
	else:
		set_value([false, clamp(float(local_bpm_edit_node.text), local_min_value, local_max_value), property.value[2]])

func _update_local_slider_state():
	local_slider_node.set_block_signals(true)
	local_slider_node.value = clamp(property.value[1], local_min_slider, local_max_slider)
	local_slider_node.set_block_signals(false)

func setup():
	local_slider_node.step = local_step_slider
	local_slider_node.min_value = property.value[1]
	local_slider_node.max_value = property.value[1]
	local_slider_node.value = property.value[1]
	local_slider_node.min_value = local_min_slider
	local_slider_node.max_value = local_max_slider
	
	set_value([property.value[0], Constants.global_bpm, property.value[2]])

func _on_local_slider_value_changed(new_value: float) -> void:
	temp_value = new_value
	local_bpm_edit_node.text = str(new_value)

func _on_local_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		set_value([false, temp_value, property.value[2]])

# GLOBAL ====================================================
func _on_global_bpm_text_changed(new_text: String) -> void:
	if new_text == "":
		return

	var filtered := ""
	for c in new_text:
		if (c >= "0" and c <= "9") or c == "-" or c ==".":
			filtered += c

	if filtered != new_text:
		var caret := global_bpm_edit_node.caret_column
		Constants.global_bpm = float(filtered)
		global_bpm_edit_node.text = filtered
		global_bpm_edit_node.caret_column = min(caret, filtered.length())

func _on_global_bpm_text_submitted(new_text: String) -> void:
	if global_bpm_edit_node.text == "":
		Constants.global_bpm = global_min_bpm
	else:
		Constants.global_bpm = clamp(float(global_bpm_edit_node.text), global_min_bpm, global_max_bpm)
	global_bpm_edit_node.text = str(Constants.global_bpm)

func _on_global_mult_text_changed(new_text: String) -> void:
	if new_text == "":
		return

	var filtered := ""
	for c in new_text:
		if (c >= "0" and c <= "9") or c == "-":
			filtered += c

	if filtered != new_text:
		var caret := global_mult_edit_node.caret_column
		set_value([true, property.value[1], filtered])
		global_mult_edit_node.caret_column = min(caret, filtered.length())

func _on_global_mult_text_submitted(new_text: String) -> void:
	if global_mult_edit_node.text == "":
		set_value([true, property.value[1], global_min_mult])
	else:
		set_value([true, property.value[1], clampi(int(global_mult_edit_node.text), global_min_mult, global_max_mult)])
