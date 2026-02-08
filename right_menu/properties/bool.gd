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

var property: RightMenuProperty 
var node: Node

func bind_to_property(prop: RightMenuProperty, target_node: Node) -> void:
	property = prop
	node = target_node

	property_name = property.property_name
	value = property.value
	
	_load_exports()
	update_textures()

func _load_exports():
	name_node.text = property_name


func _on_texture_button_pressed() -> void:
	value = not value
	property_changed()
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

func property_changed():
	property.value = value
	node.property_changed(property)
