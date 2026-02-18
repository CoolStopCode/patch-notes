extends Node2D

var port : int
var inputoutput : bool
var hovering := false
signal clicked(port : int, inputoutput : bool)

@export var port_texture : Texture
@export var hover_texture : Texture

@export var sprite : Sprite2D
func _on_button_pressed() -> void:
	clicked.emit(port, inputoutput)

func _on_button_mouse_entered() -> void:
	if inputoutput == ConnectionManager.preview_inputoutput and ConnectionManager.currently_creating_preview:
		return
	hovering = true
	update_texture()

func _on_button_mouse_exited() -> void:
	hovering = false
	update_texture()

func update_texture():
	if hovering:
		sprite.texture = hover_texture
	else:
		sprite.texture = port_texture
