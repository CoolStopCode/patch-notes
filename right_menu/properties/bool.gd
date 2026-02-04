extends Control

@export var property_name: String
@export var value: bool

@export var name_node : Label
@export var button_node : TextureButton

@export var off_texture : Texture
@export var off_press_texture : Texture
@export var off_hover_texture : Texture
@export var on_texture : Texture
@export var on_press_texture : Texture
@export var on_hover_texture : Texture

func load_exports():
	name_node.text = property_name

func _ready() -> void:
	update_textures()


func _on_texture_button_pressed() -> void:
	value = not value
	update_textures()

func update_textures():
	if value:
		button_node.texture_normal = on_texture 
		button_node.texture_pressed = on_press_texture 
		button_node.texture_hover = on_hover_texture
	else:
		button_node.texture_normal = off_texture 
		button_node.texture_pressed = off_press_texture 
		button_node.texture_hover = off_hover_texture
