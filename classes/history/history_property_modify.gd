class_name HistoryPropertyModify
extends HistoryAction

var properties : Array[InspectorProperty]
var from : Variant
var to : Variant

func undo():
	for property in properties:
		property.value = from
		property.value_changed.emit()

func redo():
	for property in properties:
		property.value = to
		property.value_changed.emit()

func _init(_properties : Array[InspectorProperty], _from : Variant, _to : Variant) -> void:
	name = "Property Modify"
	properties = _properties
	from = _from
	to = _to
