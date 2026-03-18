class_name Note
extends Resource

@export var note : Constants.Note
@export var accidental : Constants.Accidental
@export var octave : int

func _init(_note : Constants.Note = Constants.Note.A,
			_accidental : Constants.Accidental = Constants.Accidental.NORMAL,
			_octave : int = 0):
	note = _note
	accidental = _accidental
	octave = _octave
