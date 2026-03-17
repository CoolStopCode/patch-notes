class_name Note
extends Resource

@export var note : Constants.Note
@export var accidental : Constants.Accidental

func _init(_note : Constants.Note = Constants.Note.A, _accidental : Constants.Accidental = Constants.Accidental.NORMAL):
	note = _note
	accidental = _accidental
