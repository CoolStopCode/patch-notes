extends Node2D

signal actuate_output(port : int)

@export var base_node : Node
var properties : Array[InspectorProperty]

@export var rect : NinePatchRect
@export var active_sprite : Sprite2D
@export var timer : Timer

var current_active : int

func _ready() -> void:
	properties = base_node.properties
	set_ports(properties[0].value)

func property_changed(property : InspectorProperty):
	if property == properties[0]:
		set_ports(properties[0].value)

func set_ports(count : int):
	base_node.BODY_SIZE = Vector2(20, 4 * count + 8)
	base_node.hover_rectangle_node.size = base_node.BODY_SIZE
	base_node.hover_rectangle_node.position = Vector2(-10, -6)
	
	var shape := RectangleShape2D.new()
	shape.set_size(base_node.BODY_SIZE)
	base_node.area_collision_node.shape = shape
	base_node.area_collision_node.position.y = (base_node.BODY_SIZE.y - 12) / 2
	
	
	rect.size = Vector2(20, 4 * count + 8)
	base_node.ports_out.clear()
	for i in range(count):
		base_node.ports_out.append(Vector2(10, 4 * i))
	
	base_node.load_out_ports()

func move_active(port):
	active_sprite.position = Vector2(0, 4 * port)
	emit_output(port)
	if current_active < properties[0].value:
		active_sprite.show()
		timer.wait_time = 60.0 / properties[1].value
		timer.start()
	else:
		active_sprite.hide()
		timer.stop()
		return

func emit_output(port := 0):
	actuate_output.emit(port)

func receive_input(_port := 0):
	start_progression()

func start_progression():
	current_active = 0
	move_active(0)


func _on_timer_timeout() -> void:
	current_active += 1
	move_active(current_active)
