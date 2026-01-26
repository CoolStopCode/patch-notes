extends Node2D
class_name BaseNode

signal actuate_output(port : int)

@export var NODE_SCENE : PackedScene
var node : Node

@export_group("Body")
@export var BODY_SIZE : Vector2
@export var BODY_SPRITE : Texture2D

@export_group("Connections")
@export var connections_in : Array[Vector2]
@export var connections_out : Array[Vector2]

@export_group("Nodes (private)")
@export var hover_rectangle_node : ColorRect
@export var body_sprite_node : Sprite2D
@export var area_node : Area2D
@export var area_collision_node : CollisionShape2D
@export var inputs_node : Node
@export var outputs_node : Node
@export var CONNECTION_SCENE : PackedScene

signal mouse_hovering_changed(value: bool)
var mouse_hovering := false:
	set(value):
		if mouse_hovering == value:
			return
		mouse_hovering = value
		mouse_hovering_changed.emit(value)
var mouse_dragging := false
var drag_offset : Vector2

func _ready():
	node = load_node(NODE_SCENE)
	node.actuate_output.connect(emit_output)
	add_child(node)
	initiate_children()

func load_node(node_scene):
	var node_instance = node_scene.instantiate()
	return node_instance

func emit_output(port := 0):
	actuate_output.emit(port)

func receive_input(port := 0):
	node.receive_input(port)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and mouse_hovering:
			drag_offset = global_position - get_global_mouse_position()
			mouse_dragging = true
			Cursor.dragging = true
		else:
			if mouse_dragging:
				Cursor.dragging = false
			mouse_dragging = false

	if event is InputEventMouseMotion and mouse_dragging:
		var free_pos := get_global_mouse_position() + drag_offset
		global_position = Constants.snap_to_grid(free_pos)

func _process(_delta: float) -> void:
	if mouse_dragging:
		var free_pos := get_global_mouse_position() + drag_offset
		global_position = Constants.snap_to_grid(free_pos)

func initiate_children():
	hover_rectangle_node.size = BODY_SIZE
	hover_rectangle_node.position = -BODY_SIZE * 0.5
	
	body_sprite_node.texture = BODY_SPRITE
	
	var shape := RectangleShape2D.new()
	shape.set_size(BODY_SIZE)
	area_collision_node.shape = shape
	
	area_node.mouse_entered.connect(func(): mouse_hovering = true)
	area_node.mouse_exited.connect(func(): mouse_hovering = false)
	mouse_hovering_changed.connect(func(value): 
		hover_rectangle_node.visible = value
		Cursor.hovering = value
	)
	hover_rectangle_node.visible = false
	
	var i := 0
	for pos in connections_in:
		var connection_node = load_node(CONNECTION_SCENE)
		connection_node.position = pos
		connection_node.port = i
		connection_node.inputoutput = true
		connection_node.clicked.connect(connection_clicked)
		inputs_node.add_child(connection_node)
		i += 1
	i = 0
	for pos in connections_out:
		var connection_node = load_node(CONNECTION_SCENE)
		connection_node.position = pos
		connection_node.port = i
		connection_node.inputoutput = false
		connection_node.clicked.connect(connection_clicked)
		outputs_node.add_child(connection_node)
		i += 1

func connection_clicked(port, inputoutput):
	print(port, inputoutput)
