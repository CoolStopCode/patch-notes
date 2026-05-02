extends Node2D

signal actuate_output(port : int)

@export var base_node : Node
var properties : Array[InspectorProperty]

@export var rect : NinePatchRect
@export var active_sprite : Sprite2D
@export var timer : Timer

var current_active : int
var last_beat : int
var running : bool

func _ready() -> void:
	properties = base_node.properties
	set_ports(properties[0].value)

func property_changed(property : InspectorProperty):
	if property == properties[0]:
		set_ports(properties[0].value)

func set_ports(count : int):
	base_node.BODY_SIZE = Vector2(20, 4 * count + 16)
	base_node.hover_rectangle_node.size = base_node.BODY_SIZE
	base_node.hover_rectangle_node.position = Vector2(-10, -10)
	
	var shape := RectangleShape2D.new()
	shape.set_size(base_node.BODY_SIZE)
	base_node.area_collision_node.shape = shape
	base_node.area_collision_node.position.y = (base_node.BODY_SIZE.y - 16) / 2
	base_node.selected_outline.size = shape.size + Vector2(2, 2)
	base_node.selected_outline.position = Vector2(-11, -11)
	
	rect.size = Vector2(20, 4 * count + 16)
	base_node.ports_out.clear()
	for i in range(count):
		var port := Port.new(Vector2(10, 4 * i), Constants.Axis.HORIZONTAL)
		base_node.ports_out.append(port)
	
	base_node.ports_out.append(Port.new(Vector2(0, 4 * count + 6), Constants.Axis.VERTICAL))
	base_node.load_out_ports()

func move_active(port):
	active_sprite.position = Vector2(0, 4 * port)
	emit_output(port)
	if current_active < properties[0].value:
		active_sprite.show()
		timer.wait_time = 60.0 / properties[1].value
		timer.start()
	elif current_active == properties[0].value:
		active_sprite.hide()
		timer.wait_time = 60.0 / properties[1].value
		timer.start()
	else:
		running = false
		active_sprite.hide()
		timer.stop()
		return

func emit_output(port := 0):
	actuate_output.emit(port)

func receive_input(_port := 0):
	start_progression()

func start_progression():
	last_beat = int(Constants.global_time / (60.0 / properties[1].value))
	current_active = 0
	running = true
	move_active(0)


func _on_timer_timeout() -> void:
	if properties[2].value: return
	
	current_active += 1
	move_active(current_active)

func _process(delta: float) -> void:
	if not running: return
	if not properties[2].value: return
	
	var bpm = properties[1].value
	var beat = int(Constants.global_time / (60.0 / bpm))

	if beat != last_beat:
		last_beat = beat
		current_active += 1
		move_active(current_active)
