extends Node2D

signal actuate_output(port : int)

@export var base_node : Node
var properties : Array[InspectorProperty]

@export var audio_node : AudioStreamPlayer
@export var label : Label
@export var default_audio_file : AudioStream
@export var audio_file : AudioStream
var calculated_pitch : float
var pulse_tween : Tween

func _ready() -> void:
	properties = base_node.properties
	calculated_pitch = calculate_pitch(properties[2].value, properties[3].value)
	audio_node.stream = load(properties[0].value) if properties[0].value else audio_file
	update_label()

func property_changed(property : InspectorProperty):
	if property == properties[3]:
		update_label()
	if property == properties[2] or property == properties[3]:
		calculated_pitch = calculate_pitch(properties[2].value, properties[3].value)
	if property == properties[0]:
		if properties[0].value == null:
			audio_file = default_audio_file
		else:
			audio_file = load(property.value)
		audio_node.stream = audio_file

func emit_output(port := 0):
	actuate_output.emit(port)

func receive_input(_port := 0):
	audio_node.pitch_scale = calculated_pitch
	audio_node.volume_linear = properties[1].value
	audio_node.play()
	pulse()
	emit_output(0)

func update_label():
	var note := Constants.note_to_letter(properties[3].value.note)
	var accidental := Constants.accidental_to_letter(properties[3].value.accidental)
	label.text = note + accidental
	if accidental.is_empty():
		label.position.x = -4.0
	else:
		label.position.x = -7.0

func note_to_semitone(n: Note) -> int:
	var base := 0

	match n.note:
		Constants.Note.C:
			base = 0
		Constants.Note.D:
			base = 2
		Constants.Note.E:
			base = 4
		Constants.Note.F:
			base = 5
		Constants.Note.G:
			base = 7
		Constants.Note.A:
			base = 9
		Constants.Note.B:
			base = 11
		_:
			return 0
	
	var shift := -1
	match n.accidental:
		Constants.Accidental.NORMAL:
			shift = 0
		Constants.Accidental.FLAT:
			shift = -1
		Constants.Accidental.SHARP:
			shift = 1
	return base + shift + (n.octave * 12)

func calculate_pitch(from : Note, to : Note):
	var a = note_to_semitone(from)
	var b = note_to_semitone(to)
	
	var diff = b - a
	return pow(2.0, diff / 12.0)

func pulse():
	if pulse_tween and pulse_tween.is_running():
		pulse_tween.kill()

	pulse_tween = create_tween()
	pulse_tween.set_trans(Tween.TRANS_CIRC)
	pulse_tween.set_ease(Tween.EASE_OUT)

	var base := Color(1, 1, 1)
	var bright := base * 2.0
	
	pulse_tween.tween_property(base_node.body_sprite_node, "modulate", base, 0.3).from(bright)
