extends Camera2D

@export var zoom_min := 1.0
@export var zoom_max := 20.0
@export var zoom_speed := 0.01
@export var pan_speed := 10.0

@export var parallax : Parallax2D
@export var start_hide_parallax := 3.0
@export var end_hide_parallax := 1.4

var last_mouse_screen := Vector2.ZERO

func _input(event):
	if event is InputEventMouseMotion:
		last_mouse_screen = event.position

	elif event is InputEventPanGesture:
		if event.ctrl_pressed:
			_zoom_at_screen_pos(last_mouse_screen, event.delta.y)
		else:
			position += event.delta * pan_speed / zoom.x


func _zoom_at_screen_pos(screen_pos: Vector2, delta_y: float) -> void:
	var before := screen_to_world(screen_pos)

	var zoom_factor := 1.0 - delta_y * zoom_speed
	zoom *= zoom_factor
	zoom = zoom.clamp(Vector2(zoom_min, zoom_min), Vector2(zoom_max, zoom_max))
	var t := inverse_lerp(start_hide_parallax, end_hide_parallax, zoom.x)

	parallax.modulate.a = lerp(1.0, 0.0, t)
	parallax.visible = zoom.x >= end_hide_parallax
	
	var after := screen_to_world(screen_pos)
	position += before - after


func screen_to_world(screen_pos: Vector2) -> Vector2:
	return global_position \
		+ (screen_pos - get_viewport_rect().size * 0.5) / zoom
