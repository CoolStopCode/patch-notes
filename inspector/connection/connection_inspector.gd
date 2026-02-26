extends Control

signal other_color_button_pressed
@export var colors_parent : Node
@export var color_button_scene : PackedScene
@export var colors : Array[Color]

var active_connection : Connection
var active := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for col in colors:
		var color_button_instance := color_button_scene.instantiate()
		color_button_instance.color = col
		color_button_instance.color_button_pressed.connect(color_button_pressed)
		other_color_button_pressed.connect(color_button_instance.other_color_button_pressed)
		colors_parent.add_child(color_button_instance)

func open(connection : Connection):
	active_connection = connection
	show()
	active = true
	other_color_button_pressed.emit()
	for color_button in colors_parent.get_children():
		if color_button.color == connection.color:
			color_button.selected_rect.show()

func close():
	if not active: return
	active_connection.deselected()
	hide()
	active = false

func color_button_pressed(button : Button):
	other_color_button_pressed.emit()
	button.selected_rect.show()
	active_connection.set_line_color(button.color)

func _input(event: InputEvent) -> void:
	if not active: return

	if event is InputEventMouseButton and event.pressed:
		var pos := get_global_mouse_position()
		if not get_global_rect().has_point(pos):
			close()
