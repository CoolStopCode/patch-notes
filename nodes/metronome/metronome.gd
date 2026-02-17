extends Node2D

signal actuate_output(port : int)

@export var base_node : Node

@export var timer : Timer
@export var sprite : Sprite2D
@export var audio : AudioStreamPlayer
@export var sprite_left : Texture
@export var sprite_right : Texture
@export var button : TextureButton

var running := false
var hovering := false
var pulse_tween : Tween
var properties : Array[InspectorProperty]

func _ready() -> void:
	properties = base_node.properties

func property_changed(property : InspectorProperty):
	if property == properties[0]:
		timer.wait_time = 60.0 / property.value

func emit_output(port := 0):
	actuate_output.emit(port)

func receive_input(_port := 0):
	pass

func pulse():
	if sprite.texture == sprite_left:
		sprite.texture = sprite_right
	else:
		sprite.texture = sprite_left
	
	if pulse_tween and pulse_tween.is_running():
		pulse_tween.kill()

	pulse_tween = create_tween()
	pulse_tween.set_trans(Tween.TRANS_CIRC)
	pulse_tween.set_ease(Tween.EASE_OUT)

	var base := Color(1, 1, 1)
	var bright := base * 2.0
	
	if properties[1].value:
		audio.play()
	pulse_tween.tween_property(base_node.body_sprite_node, "modulate", base, 0.3).from(bright)

func start_drag():
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE

func end_drag():
	button.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_button_pressed() -> void:
	if running:
		timer.stop()
		running = false
	else:
		timer.start()
		_on_timer_timeout()
		running = true


func _on_timer_timeout() -> void:
	pulse()
	emit_output(0)
	emit_output(1)
	emit_output(2)


func _on_button_mouse_entered() -> void:
	hovering = true
	sprite.modulate = Color(1.2, 1.2, 1.2)

func _on_button_mouse_exited() -> void:
	hovering = true
	sprite.modulate = Color(1.0, 1.0, 1.0)
	


func _on_button_button_down() -> void:
	sprite.modulate = Color(0.7, 0.7, 0.7)


func _on_button_button_up() -> void:
	sprite.modulate = Color(1.2, 1.2, 1.2)
