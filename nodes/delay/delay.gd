extends Node2D

signal actuate_output(port : int)

@export var properties : Array[RightMenuProperty]
@export var base_node : Node

func emit_output(port := 0):
	actuate_output.emit(port)

func receive_input(_port := 0):
	print(properties[0].value)
	await get_tree().create_timer(properties[0].value).timeout
	emit_output(0)
