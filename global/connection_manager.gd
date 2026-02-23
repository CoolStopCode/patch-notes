extends Node

var connections : Array[Connection] = []

var currently_creating_preview := false
var preview_inputoutput : bool
var preview_from : Node
var preview_port : int

var hovering_port : Port
signal connection_started(from : Node, port : int)
signal connection_ended(to : Node, port : int)
signal connection_quit

func _ready() -> void:
	connection_started.connect(on_connection_started)
	connection_ended.connect(on_connection_ended)
	connection_quit.connect(on_connection_quit)

func on_connection_started(from : Node, port : int, inputoutput : bool):
	preview_from = from
	preview_port = port
	currently_creating_preview = true
	preview_inputoutput = inputoutput

func on_connection_ended(_to : Node, _port : int, _inputoutput : bool):
	currently_creating_preview = false

func on_connection_quit():
	currently_creating_preview = false
