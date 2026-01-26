extends Node2D

var port : int
var inputoutput : bool
signal clicked(port : int, inputoutput : bool)

func _on_button_pressed() -> void:
	clicked.emit(port, inputoutput)
