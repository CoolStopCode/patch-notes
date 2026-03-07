class_name CheckboxInspectorTool
extends BaseInspectorTool

@export var texture_rect : TextureRect

@export var off_texture : Texture
@export var on_texture : Texture

func update_value(value : Variant):
	update_textures()

func update_textures():
	if property.value:
		texture_rect.texture = on_texture 
	else:
		texture_rect.texture = off_texture 

func _on_button_pressed() -> void:
	set_value(not property.value)
