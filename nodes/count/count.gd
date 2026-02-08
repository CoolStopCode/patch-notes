extends Node2D

signal actuate_output(port : int)

@export var properties : Array[RightMenuProperty]
@export var base_node : Node

var current_count := 0

func _ready() -> void:
	pass

func property_changed(_property : RightMenuProperty):
	pass

func emit_output(port := 0):
	actuate_output.emit(port)

func receive_input(_port := 0):
	current_count += 1
	if current_count >= properties[0].value:
		current_count = 0
		emit_output(0)
