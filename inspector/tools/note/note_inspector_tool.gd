class_name NoteInspectorTool
extends BaseInspectorTool

@export var note_text : Label
@export var note_button : Button
@export var note_underline : ColorRect
@export var accidental_texture_rect : TextureRect
@export var accidental_to_texture : Dictionary[Constants.Accidental, Texture]

var note_active := false

func setup():
	pass

func update_value(value : Variant):
	update_textures()


func _on_note_pressed() -> void:
	note_active = true
	note_underline.show()
	var current_note = property.value.note
	var current_accidental = property.value.accidental
	var new_note = (current_note + 1) % Constants.Note.size()
	set_value(Note.new(new_note , current_accidental))

func _on_accidental_pressed() -> void:
	var current_note = property.value.note
	var current_accidental = property.value.accidental
	var new_accidental = (current_accidental + 1) % Constants.Accidental.size()
	set_value(Note.new(current_note, new_accidental))

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
				set_value(Note.new(note, current_accidental))
				break
