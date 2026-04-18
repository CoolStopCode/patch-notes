extends Node2D

signal actuate_output(port : int)

@export var base_node : Node
var properties : Array[InspectorProperty]

func _ready() -> void:
	properties = base_node.properties

func property_changed(_property : InspectorProperty):
	pass

func emit_output(port := 0):
	actuate_output.emit(port)

func receive_input(_port := 0):
	await get_tree().create_timer(properties[0].value).timeout
	emit_output(0)
