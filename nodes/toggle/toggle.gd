extends Node2D

signal actuate_output(port : int)

@export var properties : Array[RightMenuProperty]
@export var base_node : Node

@export var on_texture : Texture
@export var off_texture : Texture
@export var on_hover_texture : Texture
@export var off_hover_texture : Texture

@export var button_node : TextureButton

var toggled := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_texture()

func property_changed(_property : RightMenuProperty):
	pass

func emit_output(port := 0):
	actuate_output.emit(port)

func receive_input(_port := 0):
	if toggled:
		emit_output(0)

func start_drag():
	button_node.mouse_filter = Control.MOUSE_FILTER_IGNORE

func end_drag():
	button_node.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_texture_button_pressed() -> void:
	toggled = not toggled
	update_texture()

func update_texture():
	if toggled:
		button_node.texture_hover = on_hover_texture
		button_node.texture_normal = on_texture
	else:
		button_node.texture_hover = off_hover_texture
		button_node.texture_normal = off_texture
