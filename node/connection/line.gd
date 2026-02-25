extends Node2D

signal pressed
@export var outline : Line2D
@export var line : Line2D

func is_mouse_on_line(line: Line2D, mouse: Vector2, tolerance := 4.0) -> bool:
	var local_mouse = line.to_local(mouse)

	var pts = line.points
	for i in range(pts.size() - 1):
		var a = pts[i]
		var b = pts[i + 1]

		# vertical
		if a.x == b.x:
			if abs(local_mouse.x - a.x) <= tolerance:
				if local_mouse.y >= min(a.y, b.y) and local_mouse.y <= max(a.y, b.y):
					return true

		# horizontal
		elif a.y == b.y:
			if abs(local_mouse.y - a.y) <= tolerance:
				if local_mouse.x >= min(a.x, b.x) and local_mouse.x <= max(a.x, b.x):
					return true

	return false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if is_mouse_on_line(line, get_global_mouse_position(), line.width):
				selected()
				pressed.emit()

func selected():
	outline.show()

func deselected():
	outline.hide()
