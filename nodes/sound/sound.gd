extends Node2D

signal actuate_output(port : int)

@export var properties : Array[RightMenuProperty]
@export var base_node : Node

@export var audio_node : AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func property_changed(property : RightMenuProperty):
	if property == properties[0]:
		audio_node.stream = load(property.path)

func emit_output(port := 0):
	actuate_output.emit(port)

func receive_input(_port := 0):
	audio_node.pitch_scale = properties[2].value
	audio_node.volume_linear = properties[1].value
	print(properties[1].value)
	audio_node.play()
	emit_output(0)
