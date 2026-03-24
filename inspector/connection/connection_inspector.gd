extends Control

signal color_set(color : Color)
@export var state_button : Button
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
		color_button_instance.color_button_pressed.connect(set_color)
		color_set.connect(color_button_instance.color_set)
		colors_parent.add_child(color_button_instance)

func open(connection : Connection):
	active_connection = connection
	show()
	active = true
	color_set.emit(connection.color)
	state_button.load_state(connection.connection_state)
	for color_button in colors_parent.get_children():
		if color_button.color == connection.color:
			color_button.selected_rect.show()

func update():
	color_set.emit(active_connection.color)
	state_button.load_state(active_connection.connection_state)
	for color_button in colors_parent.get_children():
		if color_button.color == active_connection.color:
			color_button.selected_rect.show()

func close():
	if not active: return
	active_connection.deselected()
	hide()
	active = false

func set_color(color : Color):
	History.commit(HistoryConnectionColorModify.new(
		active_connection.ID,
		active_connection.color,
		color
	))
	color_set.emit(color)
	active_connection.set_line_color(color)

func _input(event: InputEvent) -> void:
	if not active: return

	if event is InputEventMouseButton and event.pressed:
		var pos := get_global_mouse_position()
		if not get_global_rect().has_point(pos):
			close()

func _on_state_set(state: Constants.ConnectionState) -> void:
	if active:
		History.commit(HistoryConnectionStateModify.new(
			active_connection.ID,
			active_connection.connection_state,
			state
		))
		active_connection.connection_state = state

func update_state_button():
	if active:
		state_button.apply_state(active_connection.connection_state)

func _on_delete_pressed() -> void:
	if active:
		History.commit(HistoryConnectionDelete.new(
			active_connection.ID,
			active_connection.from.ID,
			active_connection.from_port,
			active_connection.to.ID,
			active_connection.to_port,
			active_connection.line.line.points,
			active_connection.color,
			active_connection.connection_state
		))
		active_connection.free_connection()
		close()
