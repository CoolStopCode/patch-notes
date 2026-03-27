extends Node

@export var DEV_MODE := false
@export var GRID_SIZE := Vector2(4, 4)
@export var PACK_LIST : PackList = load("res://nodes/pack_list.tres")
@export var DEFAULT_CONNECTION_COLOR : Color = Color("394a50")
@export var global_time : float = 0.0
@export var DISTANCE_TO_START_DRAG : float = 4.0
enum NodeState {
	NORMAL,
	PASS,
	BROKEN
}
enum ConnectionState {
	NORMAL,
	BROKEN
}
enum Axis { HORIZONTAL, VERTICAL }

enum Note {
	A,
	B,
	C,
	D,
	E,
	F,
	G
}
enum Accidental {
	NORMAL,
	FLAT,
	SHARP
}

func snap_to_grid(pos) -> Vector2:
	return snapped(pos, GRID_SIZE)

func clear_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func _process(delta: float) -> void:
	global_time += delta

func deep_duplicate_properties(props: Array[InspectorProperty]) -> Array[InspectorProperty]:
	var copy : Array[InspectorProperty] = []
	for p in props:
		copy.append(p.duplicate(true))
	return copy

func _ready() -> void:
	DEV_MODE = OS.has_feature("editor") or "-dev" in OS.get_cmdline_args()
	if DEV_MODE: print("===================\n  DEV MODE ACTIVE  \n===================\n")

func is_approx_equal(a: float, b: float, precision: float) -> bool:
	return abs(a - b) <= precision

func is_approx_equal_vec2(a: Vector2, b: Vector2, precision: float) -> bool:
	return a.distance_to(b) <= precision

func note_to_letter(note : Constants.Note) -> String:
	var key : Dictionary[Constants.Note, String] = {
		Constants.Note.A: "A",
		Constants.Note.B: "B",
		Constants.Note.C: "C",
		Constants.Note.D: "D",
		Constants.Note.E: "E",
		Constants.Note.F: "F",
		Constants.Note.G: "G"
	}
	return key[note]

func letter_to_note(letter : String) -> Constants.Note:
	var key : Dictionary[String, Constants.Note] = {
		"A": Constants.Note.A,
		"B": Constants.Note.B,
		"C": Constants.Note.C,
		"D": Constants.Note.D,
		"E": Constants.Note.E,
		"F": Constants.Note.F,
		"G": Constants.Note.G
	}
	return key[letter]

func accidental_to_letter(accidental : Constants.Accidental) -> String:
	var key : Dictionary[Constants.Accidental, String] = {
		Constants.Accidental.NORMAL: "",
		Constants.Accidental.SHARP: "#",
		Constants.Accidental.FLAT: "b"
	}
	return key[accidental]
