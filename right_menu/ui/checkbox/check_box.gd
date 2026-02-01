extends Button

signal button_toggled(value)
var value: bool = false
var is_button_hovered: bool = false
var is_button_pressed: bool = false

@export var true_texture: Texture
@export var false_texture: Texture
@export var true_hover_texture: Texture
@export var false_hover_texture: Texture
@export var true_pressed_texture: Texture
@export var false_pressed_texture: Texture
@export var sprite: Sprite2D

func _ready() -> void:
	_update_texture()

func _on_mouse_entered() -> void:
	is_button_hovered = true
	_update_texture()

func _on_mouse_exited() -> void:
	is_button_hovered = false
	_update_texture()

func _on_button_down() -> void:
	is_button_pressed = true
	_update_texture()

func _on_button_up() -> void:
	is_button_pressed = false
	_update_texture()

func _on_pressed() -> void:
	value = !value
	_update_texture()
	emit_signal("button_toggled", value)

func _update_texture() -> void:
	if is_button_pressed:
		# Pressed textures have highest priority
		sprite.texture = true_pressed_texture if value else false_pressed_texture
		if sprite.texture == null: 
			sprite.texture = true_texture if value else false_texture
	elif is_button_hovered:
		# Hover textures next
		sprite.texture = true_hover_texture if value else false_hover_texture
		if sprite.texture == null:
			sprite.texture = true_texture if value else false_texture
	else:
		# Normal textures
		sprite.texture = true_texture if value else false_texture
