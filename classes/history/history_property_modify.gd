class_name HistoryPropertyModify
extends HistoryAction

var property : InspectorProperty
var from : Variant
var to : Variant

func undo():
	print("SETTING TO ", from)
	property.value = from
	property.value_changed.emit()

func redo():
	property.value = to
	property.value_changed.emit()

func _init(_property : InspectorProperty, _from : Variant, _to : Variant) -> void:
	name = "Property Modify"
	property = _property
	from = _from
	to = _to
