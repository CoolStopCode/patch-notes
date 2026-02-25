extends Button

signal color_button_pressed(color : Color)
@export var color : Color
@export var color_rect : ColorRect
@export var selected_rect : TextureRect

func _ready() -> void:
	color_rect.color = color

func _on_pressed() -> void:
	color_button_pressed.emit(self)

func other_color_button_pressed():
	selected_rect.hide()
