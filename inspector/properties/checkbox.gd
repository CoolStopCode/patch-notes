extends Control

@export var property_name: String
@export var value: bool

@export var name_node : Label
@export var texture_rect : TextureRect

@export var off_texture : Texture
@export var on_texture : Texture

var property: InspectorProperty 
var node: Node

func bind_to_property(prop: InspectorProperty, target_node: Node) -> void:
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
	var old_properties = Constants.deep_duplicate_properties(node.properties)
	property.value = value
	var new_properties = Constants.deep_duplicate_properties(node.properties)
	History.commit(HistoryPropertyModify.new(node.ID, old_properties, new_properties))
	node.property_changed(old_properties, new_properties, property)


func _on_button_pressed() -> void:
	value = not value
	property_changed()
	update_textures()
