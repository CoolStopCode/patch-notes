extends Node2D

signal actuate_output(port : int)

@export var base_node : Node

@export var progress_bar : ColorRect
var current_count := 0
var properties : Array[InspectorProperty]

func _ready() -> void:
	properties = base_node.properties
	update_progress_bar()

func property_changed(_property : InspectorProperty):
	pass

func emit_output(port := 0):
	actuate_output.emit(port)

func receive_input(_port := 0):
	current_count += 1
	if current_count >= properties[0].value:
		current_count = 0
		emit_output(0)
	update_progress_bar()

func update_progress_bar():
	if properties[0].value - 1 == 0:
		progress_bar.size.x = 6.0
		return
	var progress : float = float(current_count) / float(properties[0].value - 1)
	progress_bar.size.x = round(progress * 6)
