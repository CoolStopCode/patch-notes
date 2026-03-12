extends Control

signal category_opened(category : NodeList)
var category : NodeList
@export var icon : TextureRect
@export var text : Label

func _on_open_pressed() -> void:
	category_opened.emit(category)
