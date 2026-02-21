class_name Port
extends Resource

@export var position : Vector2
@export var axis : Constants.Axis

func _init(_position : Vector2 = Vector2(0, 0), _axis: Constants.Axis = Constants.Axis.HORIZONTAL):
	position = _position
	axis = _axis
