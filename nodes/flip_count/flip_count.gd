extends Node2D

signal actuate_output(port : int)

@export var properties : Array[InspectorProperty]
@export var base_node : Node

@export var progress_bar : ColorRect
@export var flip_sprite : Sprite2D
@export var bottom_texture : Texture
@export var top_texture : Texture

var current_count := 0
var outputting_top := false

func _ready() -> void:
	update_sprites()

func property_changed(_property : InspectorProperty):
	pass

func emit_output(port := 0):
	actuate_output.emit(port)

func receive_input(_port := 0):
	current_count += 1
	if current_count >= properties[0].value:
		current_count = 0
		outputting_top = not outputting_top
	
	if outputting_top:
		emit_output(1)
	else:
		emit_output(0)
	update_sprites()

func update_sprites():
	if outputting_top:
		flip_sprite.texture = top_texture
	else:
		flip_sprite.texture = bottom_texture
	
	if properties[0].value - 1 == 0:
		progress_bar.size.x = 12.0
		return
	var progress : float = float(current_count) / float(properties[0].value - 1)
	progress_bar.size.x = round(progress * 12)
