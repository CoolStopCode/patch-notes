class_name InspectorProperty
extends Resource

@export var property_name: String
@export var value : Variant
@export var default_value: Variant

signal value_changed

func reset(): value = default_value
