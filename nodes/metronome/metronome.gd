extends Node2D

signal actuate_output(port : int)

@export var timer : Timer
@export var sprite : Sprite2D
@export var sprite_left : Texture
@export var sprite_right : Texture

var running := false
var hovering := false

func emit_output(port := 0):
	actuate_output.emit(port)

func receive_input(_port := 0):
	pass

func pulse():
	if sprite.texture == sprite_left:
		sprite.texture = sprite_right
	else:
		sprite.texture = sprite_left
	emit_output(0)
	emit_output(1)
	emit_output(2)


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


func _on_button_mouse_entered() -> void:
	hovering = true
	sprite.modulate = Color(1.2, 1.2, 1.2)

func _on_button_mouse_exited() -> void:
	hovering = true
	sprite.modulate = Color(1.0, 1.0, 1.0)
	
