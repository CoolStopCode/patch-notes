extends Control

@export var property_name: String
@export var value: bool

@export var name_node : Label
@export var texture_rect : TextureRect

@export var off_texture : Texture
@export var on_texture : Texture

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

func update_textures():
	if value:
		texture_rect.texture = on_texture 
	else:
		texture_rect.texture = off_texture 

func property_changed():
	property.value = value
	node.property_changed(property)


func _on_button_pressed() -> void:
	value = not value
	property_changed()
	update_textures()
