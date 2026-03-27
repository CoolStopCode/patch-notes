class_name BaseInspectorTool
extends Control

@export var name_node : Label
var property_name: String
var properties : Array[InspectorProperty]
var property : InspectorProperty

func initiate(props: Array[InspectorProperty]) -> void:
	properties = props
	property = properties[0]
	property_name = property.property_name
	name_node.text = property_name
	for prop in props:
		prop.value_changed.connect(func(): update_value(prop.value))
	setup()
	update_value(props[0].value)

func set_value(value : Variant):
	var old_value : Variant = property.value
	for prop in properties:
		prop.value = value
		prop.value_changed.emit()
	History.commit(HistoryPropertyModify.new(properties, old_value, value))
	# node.property_changed(property)

func update_value(value : Variant):
	pass

func setup():
	pass
