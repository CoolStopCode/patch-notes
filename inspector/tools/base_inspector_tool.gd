class_name BaseInspectorTool
extends Control

@export var name_node : Label
var property_name: String
var property : InspectorProperty
var node : Node

func initiate(prop: InspectorProperty, target_node: Node) -> void:
	property = prop
	node = target_node
	property_name = prop.property_name
	name_node.text = property_name
	property.value_changed.connect(func(): update_value(property.value))
	setup()
	update_value(property.value)

func set_value(value : Variant):
	var old_value : Variant = property.value
	property.value = value
	property.value_changed.emit()
	History.commit(HistoryPropertyModify.new(property, old_value, value))
	# node.property_changed(property)

func update_value(value : Variant):
	pass

func setup():
	pass
