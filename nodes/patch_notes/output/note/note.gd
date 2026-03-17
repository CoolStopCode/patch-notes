extends Node2D

signal actuate_output(port : int)

@export var base_node : Node
var properties : Array[InspectorProperty]

@export var label : Label
var calculated_pitch : float

func _ready() -> void:
	properties = base_node.properties
	update_label()

func property_changed(property : InspectorProperty):
	print(property)
	print(properties[4])
	if property == properties[4]:
		
		update_label()

func emit_output(port := 0):
	actuate_output.emit(port)

func receive_input(_port := 0):
	emit_output(0)

func update_label():
	var note := Constants.note_to_letter(properties[4].value.note)
	var accidental := Constants.accidental_to_letter(properties[4].value.accidental)
	label.text = note + accidental
	if accidental.is_empty():
		label.position.x = -4.0
	else:
		label.position.x = -7.0
