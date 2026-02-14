extends Node2D
class_name BaseNode

signal actuate_output(port : int)
signal move

@export var NODE_SCENE : PackedScene
var node : Node

@export_group("Body")
@export var BODY_SIZE : Vector2
@export var BODY_SPRITE : Texture2D
@export var ports_in : Array[Vector2]
@export var ports_out : Array[Vector2]

@export_group("Options")
@export var node_state : Constants.NodeState = Constants.NodeState.NORMAL
@export var right_menu_icon : Texture

@export_group("Nodes (private)")
@export var parent : Node
@export var hover_rectangle_node : ColorRect
@export var body_sprite_node : Sprite2D
@export var area_node : Area2D
@export var area_collision_node : CollisionShape2D
@export var inputs_node : Node
@export var outputs_node : Node
@export var PORT_SCENE : PackedScene

signal mouse_hovering_changed(value: bool)
var mouse_hovering := false

var mouse_dragging := false
var drag_offset : Vector2
var distance_moved : Vector2

func _ready():
	parent = get_parent()
	
	node = get_node_or_null("NODE")

	if node == null:
		node = load_node(NODE_SCENE)
		node.actuate_output.connect(emit_output)
		node.base_node = self
		node.name = "NODE"
		add_child(node)
	else:
		node.actuate_output.connect(emit_output)
	var duplicated_props = node.properties.map(func(p):
		return p.duplicate(true)
	)
	
	node.properties.assign(duplicated_props)
	if node.has_method("start_drag"):
		node.start_drag()
	inputs_node.move_to_front()
	outputs_node.move_to_front()
	initiate_children()

func load_node(node_scene):
	var node_instance = node_scene.instantiate()
	return node_instance

func emit_output(_port := 0):
	actuate_output.emit(_port)

func receive_input(port := 0):
	if node_state == Constants.NodeState.NORMAL:
		node.receive_input(port)
	elif node_state == Constants.NodeState.PASS:
		for p in range(ports_out.size()):
			actuate_output.emit(p)
	elif node_state == Constants.NodeState.BROKEN:
		return

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if (event.pressed and mouse_hovering) and not mouse_dragging:
			get_viewport().set_input_as_handled()
			
			distance_moved = Vector2(0, 0)
			drag_offset = global_position - get_global_mouse_position()
			mouse_dragging = true
			Cursor.dragging = true
			if node.has_method("start_drag"):
				node.start_drag()
		else:
			if mouse_dragging:
				if distance_moved == Vector2(0, 0):
					GlobalNodes.right_menu.initialize(node)
			Cursor.dragging = false
			mouse_dragging = false
			if node.has_method("end_drag"):
				node.end_drag()

	if event is InputEventMouseMotion and mouse_dragging:
		var last_pos := global_position
		var free_pos := get_global_mouse_position() + drag_offset
		parent.global_position = Constants.snap_to_grid(free_pos)
		distance_moved += abs(global_position - last_pos)
		move.emit()

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
	
	area_node.mouse_entered.connect(func():
		mouse_hovering = true
		hover_rectangle_node.visible = true
		Cursor.hovering = true
	)
	area_node.mouse_exited.connect(func(): 
		mouse_hovering = false
		hover_rectangle_node.visible = false
		Cursor.hovering = false
	)
	hover_rectangle_node.visible = false
	
	Constants.clear_children(inputs_node)
	Constants.clear_children(outputs_node)
	var i := 0
	for pos in ports_in:
		var port_node = load_node(PORT_SCENE)
		port_node.position = pos
		port_node.port = i
		port_node.inputoutput = true
		port_node.clicked.connect(port_clicked)
		port_node.name = "input" + str(i)
		inputs_node.add_child(port_node)
		i += 1
	i = 0
	for pos in ports_out:
		var port_node = load_node(PORT_SCENE)
		port_node.position = pos
		port_node.port = i
		port_node.inputoutput = false
		port_node.clicked.connect(port_clicked)
		port_node.name = "output" + str(i)
		outputs_node.add_child(port_node)
		i += 1

func port_clicked(port, inputoutput):
	if ConnectionManager.currently_creating_preview:
		if inputoutput != ConnectionManager.preview_inputoutput:
			ConnectionManager.connection_ended.emit(self, port, inputoutput)
	else:
		ConnectionManager.connection_started.emit(self, port, inputoutput)
