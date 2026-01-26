extends Node

enum CursorState {
	NORMAL,
	HOVER,
	DRAG
}

var current_state := CursorState.NORMAL

var dragging := false
var hovering := false

func _ready() -> void:
	#Input.set_custom_mouse_cursor(preload("res://assets/mouse/hand_closed.svg"), Input.CURSOR_DRAG)
	#Input.set_custom_mouse_cursor(preload("res://assets/mouse/hand_point.svg"), Input.CURSOR_POINTING_HAND)
	#Input.set_custom_mouse_cursor(preload("res://assets/mouse/pointer_a.svg"), Input.CURSOR_ARROW)
	pass
func _process(_delta: float) -> void:
	if dragging:
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)
	elif hovering:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
