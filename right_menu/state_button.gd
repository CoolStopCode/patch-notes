extends TextureButton

signal state_set(state: Constants.NodeState)

@export var normal_normal: Texture
@export var normal_pressed: Texture
@export var normal_hover: Texture

@export var pass_normal: Texture
@export var pass_pressed: Texture
@export var pass_hover: Texture

@export var broken_normal: Texture
@export var broken_pressed: Texture
@export var broken_hover: Texture

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
			set_textures(normal_normal, normal_pressed, normal_hover)
		Constants.NodeState.PASS:
			set_textures(pass_normal, pass_pressed, pass_hover)
		Constants.NodeState.BROKEN:
			set_textures(broken_normal, broken_pressed, broken_hover)


func set_textures(tex_normal: Texture, tex_pressed: Texture, tex_hover: Texture) -> void:
	texture_normal = tex_normal
	texture_pressed = tex_pressed
	texture_hover = tex_hover
