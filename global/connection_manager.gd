extends Node

var connections : Array[Connection] = []

var currently_creating_preview := false
var preview_inputoutput : bool
var preview_from : Node
var preview_port : int

signal connection_started(from : Node, port : int)
signal connection_ended(to : Node, port : int)

func _ready() -> void:
	connection_started.connect(on_connection_started)
	connection_ended.connect(on_connection_ended)

func on_connection_started(from : Node, port : int, inputoutput : bool):
	preview_from = from
	preview_port = port
	ConnectionManager.currently_creating_preview = true
	ConnectionManager.preview_inputoutput = inputoutput

func on_connection_ended(_to : Node, _port : int, _inputoutput : bool):
	ConnectionManager.currently_creating_preview = false
