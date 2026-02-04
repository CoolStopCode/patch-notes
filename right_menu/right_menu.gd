extends Control

@export var properties_container: VBoxContainer

var property_scenes: Dictionary = {
	RightMenuArrows: preload("res://right_menu/properties/arrows.tscn"),
	RightMenuBool: preload("res://right_menu/properties/bool.tscn"),
	RightMenuFile: preload("res://right_menu/properties/file.tscn"),
	RightMenuSlider: preload("res://right_menu/properties/slider.tscn")
}


func _ready() -> void:
	GlobalNodes.right_menu = self

func initialize(node : Node2D):
	for n in properties_container.get_children():
		properties_container.remove_child(n)
		n.queue_free()

	position = node.global_position
	for property: RightMenuProperty in node.properties:
		var script: Script = property.get_script()
		var ui : Control = property_scenes[script].instantiate()
		properties_container.add_child(ui)
		ui.bind_to_property(property, node)
	
	show()

func close():
	hide()
	
	for node in properties_container.get_children():
		properties_container.remove_child(node)
		node.queue_free()

func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventMouseButton and event.pressed:
		var pos := get_global_mouse_position()
		if not get_global_rect().has_point(pos):
			close()
