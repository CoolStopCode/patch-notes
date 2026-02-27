extends Button

signal state_set(state: Constants.NodeState)

@export var normal_texture: Texture
@export var broken_texture: Texture

@export var texture_rect : TextureRect
var connection_state: Constants.ConnectionState


func _ready() -> void:
	apply_state(connection_state)


func _on_pressed() -> void:
	connection_state = Constants.ConnectionState.values()[
		(connection_state + 1) % Constants.ConnectionState.size()
	]

	apply_state(connection_state)
	state_set.emit(connection_state)


func load_state(state: Constants.ConnectionState) -> void:
	connection_state = state
	apply_state(connection_state)


func apply_state(state: Constants.ConnectionState) -> void:
	match state:
		Constants.ConnectionState.NORMAL:
			texture_rect.texture = normal_texture
		Constants.ConnectionState.BROKEN:
			texture_rect.texture = broken_texture
