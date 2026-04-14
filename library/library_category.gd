extends Control

signal category_opened(category : Extension)
var category : Extension
@export var icon : TextureRect
@export var text : Label

func _on_open_pressed() -> void:
	category_opened.emit(category)
