class_name HistoryPropertyModify
extends HistoryAction

var properties : Array[InspectorProperty]
var froms : Array[Variant]
var to : Variant

func undo():
	for i in range(properties.size()):
		var property = properties[i]
		property.value = froms[i]
		property.value_changed.emit()
	
func redo():
	for property in properties:
		property.value = to
		property.value_changed.emit()

func _init(_properties : Array[InspectorProperty], _froms : Array[Variant], _to : Variant) -> void:
	name = "Property Modify"
	properties = _properties
	froms = _froms
	to = _to
