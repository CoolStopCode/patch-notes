extends Node2D
class_name BaseNode

signal actuate_output(port : int)
signal move
signal ports_modified

@export var NODE_SCENE : PackedScene
@export var ID : int
var node : Node

@export_group("Body")
@export var BODY_SIZE : Vector2
@export var BODY_SPRITE : Texture2D
@export var ports_in : Array[Port]
@export var ports_out : Array[Port]

@export_group("Options")
@export var node_state : Constants.NodeState = Constants.NodeState.NORMAL
@export var right_menu_icon : Texture
@export var properties : Array[InspectorProperty]

@export_group("Nodes (private)")
@export var hover_rectangle_node : ColorRect
@export var body_sprite_node : Sprite2D
@export var area_node : Area2D
@export var area_collision_node : CollisionShape2D
@export var inputs_node : Node
@export var outputs_node : Node
@export var selected_outline : NinePatchRect
@export var PORT_SCENE : PackedScene

signal mouse_hovering_changed(value: bool)
var mouse_hovering := false
var mouse_down := false
var mouse_dragging := false
var node_selected := false

var initial_click_pos : Vector2
var drag_offset : Vector2

var creation_drag := true
var duplicate_props := true


func _ready():
	if duplicate_props:
		duplicate_properties()
	if creation_drag:
		mouse_dragging = true
		SelectionManager.start_drag(self)
	
	node = get_node_or_null("NODE")
	initiate_children()
	
	if node == null:
		node = load_node(NODE_SCENE)
		node.actuate_output.connect(emit_output)
		node.base_node = self
		node.name = "NODE"
		add_child(node)
	else:
		node.actuate_output.connect(emit_output)
	
	for property in properties:
		property.value_changed.connect(func(): property_changed(property))
	if node.has_method("start_drag"):
		node.start_drag()
	inputs_node.move_to_front()
	outputs_node.move_to_front()

func duplicate_properties():
	var new_props : Array[InspectorProperty] = []
	for p in properties:
		new_props.append(p.duplicate(true))
	properties = new_props

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
		if event.pressed:
			if mouse_hovering and not mouse_dragging: # start drag
				get_viewport().set_input_as_handled()
				initial_click_pos = get_global_mouse_position()
				drag_offset = global_position - get_global_mouse_position()
				for n in SelectionManager.selected_nodes:
					n.initial_click_pos = n.global_position
				
				mouse_down = true
		else:
			mouse_down = false
			if mouse_hovering and not mouse_dragging: # select
				var additive := Input.is_key_pressed(KEY_SHIFT)
				if not node_selected:
					SelectionManager.select(self, additive)
				else:
					if additive:
						SelectionManager.deselect(self)
					else:
						SelectionManager.select(self, false)
			else: # end drag
				mouse_dragging = false
				SelectionManager.end_drag()
				if creation_drag:
					var node_scenes : Array[PackedScene] = [load(scene_file_path)]
					var ids : Array[int] = [ID]
					var positions : Array[Vector2] = [global_position]
					var props : Array[Array] = [properties]

					History.commit(HistoryNodeCreate.new(
						node_scenes,
						ids,
						positions,
						props
					))
					creation_drag = false
				if node.has_method("end_drag"):
					node.end_drag()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if mouse_dragging:
			var motion_from_start := (get_global_mouse_position() + drag_offset) - initial_click_pos
			
			global_position = Constants.snap_to_grid(initial_click_pos + motion_from_start)
			move.emit()
			if Input.is_key_pressed(KEY_SHIFT):
				for n in SelectionManager.selected_nodes:
					if n == self: continue
					var offset = n.initial_click_pos - initial_click_pos
					n.global_position = global_position + offset
					n.move.emit()
		elif mouse_down:
			if not Constants.is_approx_equal_vec2(initial_click_pos, get_global_mouse_position(), Constants.DISTANCE_TO_START_DRAG):
				mouse_dragging = true
				SelectionManager.start_drag(self)
				if node.has_method("start_drag"):
					node.start_drag()

	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if (event.pressed and mouse_hovering) and not mouse_dragging:
			#get_viewport().set_input_as_handled()
			#
			#var additive := Input.is_key_pressed(KEY_SHIFT)
			#SelectionManager.select(self, additive)
			#
			#pre_drag_pos = global_position
			#drag_offset = global_position - get_global_mouse_position()
			#mouse_dragging = true
			#Cursor.dragging = true
			#if node.has_method("start_drag"):
				#node.start_drag()
		#elif (not event.pressed) and mouse_dragging:
			#if pre_drag_pos != global_position:
				#if node.has_method("end_drag"):
					#node.end_drag()
				#if creation_drag:
					#History.commit(HistoryNodeCreate.new(load(scene_file_path), ID, global_position, properties))
				#else:
					#var node_ids : Array[int]
					#for n in SelectionManager.selected_nodes:
						#node_ids.append(n.ID)
					#History.commit(HistoryNodeMove.new(node_ids, global_position - pre_drag_pos))
			#else:
				#if node.has_method("end_drag"):
					#node.end_drag()
				#GlobalNodes.inspector.open_node_inspector(self)
				#
				#creation_drag = false
			#Cursor.dragging = false
			#mouse_dragging = false

	#if event is InputEventMouseMotion and mouse_dragging:
		#var delta := get_global_mouse_position() - (global_position - drag_offset)
	#
		#var free_pos := get_global_mouse_position() + drag_offset
		#global_position = Constants.snap_to_grid(free_pos)
		
		#for n in SelectionManager.selected_nodes:
			#n.global_position = Constants.snap_to_grid(n.global_position + delta)
			#n.move.emit()
		#drag_offset = global_position - get_global_mouse_position()

func _process(_delta: float) -> void:
	#print(mouse_down, ", ", mouse_dragging, ", ", mouse_hovering)
	if node_selected:
		selected_outline.modulate.a = 0.35 * sin(Constants.global_time * 5.0) + 0.65

func initiate_children():
	hover_rectangle_node.size = BODY_SIZE
	hover_rectangle_node.position = -BODY_SIZE * 0.5
	selected_outline.size = BODY_SIZE + Vector2(2, 2)
	selected_outline.position = -(BODY_SIZE + Vector2(2, 2)) * 0.5
	
	body_sprite_node.texture = BODY_SPRITE
	
	var shape := RectangleShape2D.new()
	shape.set_size(BODY_SIZE)
	area_collision_node.shape = shape
	
	area_node.mouse_entered.connect(func():
		SelectionManager.start_hover(self)
	)
	area_node.mouse_exited.connect(func(): 
		SelectionManager.end_hover(self)
	)
	hover_rectangle_node.visible = false
	
	load_in_ports()
	load_out_ports()

func load_in_ports():
	ports_modified.emit()
	Constants.clear_children(inputs_node)
	var i := 0
	for port in ports_in:
		port = port.duplicate()
		var port_node = load_node(PORT_SCENE)
		port_node.position = port.position
		port_node.port = i
		port_node.port_object = port
		port_node.inputoutput = true
		port_node.clicked.connect(port_clicked)
		port_node.name = "input" + str(i)
		port.parent = self
		inputs_node.add_child(port_node)
		i += 1

func load_out_ports():
	ports_modified.emit()
	Constants.clear_children(outputs_node)
	var i := 0
	for port in ports_out:
		port = port.duplicate()
		var port_node = load_node(PORT_SCENE)
		port_node.position = port.position
		port_node.port = i
		port_node.port_object = port
		port_node.inputoutput = false
		port_node.clicked.connect(port_clicked)
		port_node.name = "output" + str(i)
		port.parent = self
		outputs_node.add_child(port_node)
		i += 1

func port_clicked(port, inputoutput):
	if ConnectionManager.currently_creating_preview:
		if inputoutput != ConnectionManager.preview_inputoutput:
			ConnectionManager.connection_ended.emit(self, port, inputoutput)
	else:
		ConnectionManager.connection_started.emit(self, port, inputoutput)

func hover_started():
	mouse_hovering = true
	hover_rectangle_node.show()

func hover_ended():
	mouse_hovering = false
	hover_rectangle_node.hide()
 
func drag_started():
	pass

func drag_ended():
	pass

func selected():
	if node.has_method("selected"):
		node.selected()
	selected_outline.show()
	node_selected = true

func deselected():
	if node.has_method("deselected"):
		node.deselected()
	selected_outline.hide()
	node_selected = false

func property_changed(property : InspectorProperty):
	if node.has_method("property_changed"):
		node.property_changed(property)
