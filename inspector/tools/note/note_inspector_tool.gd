class_name NoteInspectorTool
extends BaseInspectorTool

@export var note_text : Label
@export var note_button : Button
@export var note_underline : ColorRect
@export var accidental_texture_rect : TextureRect
@export var accidental_to_texture : Dictionary[Constants.Accidental, Texture]

@export var octave_line_edit : LineEdit
@export var octave_left_button : Button
@export var octave_right_button : Button
@export var octave_left_texture : TextureRect
@export var octave_right_texture : TextureRect

@export var left_texture_enabled: Texture
@export var left_texture_disabled: Texture
@export var right_texture_enabled: Texture
@export var right_texture_disabled: Texture

var note_active := false

func setup():
	pass

func update_value(value : Variant):
	octave_line_edit.text = str(value.octave)
	_update_button_state()
	update_textures()


func _on_note_pressed() -> void:
	note_active = true
	note_underline.show()
	var current_note = property.value.note
	var current_accidental = property.value.accidental
	var current_octave = property.value.octave
	var new_note = (current_note + 1) % Constants.Note.size()
	set_value(Note.new(new_note, current_accidental, current_octave))

func _on_accidental_pressed() -> void:
	var current_note = property.value.note
	var current_accidental = property.value.accidental
	var current_octave = property.value.octave
	var new_accidental = (current_accidental + 1) % Constants.Accidental.size()
	set_value(Note.new(current_note, new_accidental, current_octave))

func update_textures():
	note_text.text = Constants.note_to_letter(property.value.note)
	accidental_texture_rect.texture = accidental_to_texture[property.value.accidental]

func _input(event: InputEvent) -> void:
	if not note_active: return
	
	if event is InputEventMouseButton and event.pressed:
		var pos := get_global_mouse_position()
		if not note_button.get_global_rect().has_point(pos):
			note_underline.hide()
			note_active = false
	
	if event is InputEventKey and event.pressed:
		var key_string := OS.get_keycode_string(event.keycode)
		
		for note in Constants.Note.values():
			if Constants.note_to_letter(note) == key_string:
				var current_accidental = property.value.accidental
				var current_octave = property.value.octave
				set_value(Note.new(note, current_accidental, current_octave))
				break





func _on_left_pressed() -> void:
	var current_note = property.value.note
	var current_accidental = property.value.accidental
	set_value(Note.new(current_note, current_accidental, property.value.octave - 1))


func _on_right_pressed() -> void:
	var current_note = property.value.note
	var current_accidental = property.value.accidental
	set_value(Note.new(current_note, current_accidental, property.value.octave + 1))


func _on_text_changed(new_text: String) -> void:
	if new_text == "":
		return

	var filtered := ""
	for c in new_text:
		if (c >= "0" and c <= "9") or c == "-":
			filtered += c

	if filtered != new_text:
		var caret := octave_line_edit.caret_column
		var current_note = property.value.note
		var current_accidental = property.value.accidental
		set_value(Note.new(current_note, current_accidental, int(filtered)))
		octave_line_edit.caret_column = min(caret, filtered.length())

func _on_text_submitted(new_text: String) -> void:
	var current_note = property.value.note
	var current_accidental = property.value.accidental
	if octave_line_edit.text == "":
		set_value(Note.new(current_note, current_accidental, property.min_octave))
	else:
		set_value(Note.new(current_note, current_accidental, clampi(int(octave_line_edit.text), property.min_octave, property.max_octave)))

func _update_button_state():
	if property.value.octave + 1 > property.max_octave:
		octave_right_button.disabled = true
		octave_right_texture.texture = right_texture_disabled
	else:
		octave_right_button.disabled = false
		octave_right_texture.texture = right_texture_enabled
	
	if property.value.octave - 1 < property.min_octave:
		octave_left_button.disabled = true
		octave_left_texture.texture = left_texture_disabled
	else:
		octave_left_button.disabled = false
		octave_left_texture.texture = left_texture_enabled
