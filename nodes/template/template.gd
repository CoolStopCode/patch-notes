extends Node2D

signal actuate_output(port : int)

@export var properties : Array[RightMenuProperty]
@export var base_node : Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func property_changed(_property : RightMenuProperty):
	pass

func emit_output(port := 0):
	actuate_output.emit(port)

func receive_input(_port := 0):
	emit_output(0)
