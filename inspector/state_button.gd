extends Button

signal state_set(state: Constants.NodeState)

@export var normal_texture: Texture
@export var pass_texture: Texture
@export var broken_texture: Texture

@export var texture_rect : TextureRect
var node_state: Constants.NodeState = Constants.NodeState.NORMAL


func _ready() -> void:
	apply_state(node_state)


func _on_pressed() -> void:
	# Cycle to next state
	node_state = Constants.NodeState.values()[
		(node_state + 1) % Constants.NodeState.size()
	]

	apply_state(node_state)
	state_set.emit(node_state)


func load_state(state: Constants.NodeState) -> void:
	node_state = state
	apply_state(node_state)


func apply_state(state: Constants.NodeState) -> void:
	match state:
		Constants.NodeState.NORMAL:
			texture_rect.texture = normal_texture
		Constants.NodeState.PASS:
			texture_rect.texture = pass_texture
		Constants.NodeState.BROKEN:
			texture_rect.texture = broken_texture
